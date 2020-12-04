% Decide if this will be a function or script

clear
addpath(genpath('~/Modeling/modeling_code/'));
saveDir="~/Modeling/modeling_results/2020-12-03_hemibrain_batch"
% saveDir="/n/scratch2/anb12/modeling_results/2020-03-11_LN_activation_batch_y"
if ~isdir(saveDir)
    mkdir(saveDir)
end

%% Create parameter combinations

% intensities = [1, 10, 100, 1000];
intensities = [10, 100, 1e3, 1e4];
% intensities = [100, 100, 1e3];

% stimWaveforms = {'fast', 'med', 'slow', 'steps', 'square'};
% stimWaveforms = {'fast', 'med', 'slow', 'square'};
stimWaveforms = {'square'};

% scalarSteps = [0, 1, 10, 100];
scalarSteps = [0, 0.1, 1, 10];
nScalarSteps = length(scalarSteps);

%% Set model parameters
d = datetime('now', 'format', 'yyyy-MM-dd');
d = char(d);

for iStim = 1:length(stimWaveforms)
    for iInt = 1:length(intensities)
        for sORNtoORN = 1:nScalarSteps
            for sORNtoLNPN = 1:nScalarSteps
                for sPN = 1:nScalarSteps
                    for sLNtoORN = 1:nScalarSteps
                        for sLNtoLNPN = 1:nScalarSteps
                            % Set parameters
                            p.stimWav = stimWaveforms{iStim};
                            p.intensity = intensities(iInt);
                            p.baseline = 20;
                            p.ORNtoORN = scalarSteps(sORNtoORN);
                            p.ORNtoLNPN = scalarSteps(sORNtoLNPN);
                            p.PN = scalarSteps(sPN);
                            p.LNtoORN = scalarSteps(sLNtoORN);
                            p.LNtoLNPN = scalarSteps(sLNtoLNPN);
                            p.DepletionRate = 0.3e-3;
                            p.TauReplenishment = 1e3;
                            p.fname = [];
                            
                            % Set save filename
                            fname = d;
                            fields = fieldnames(p);
                            fields(find(strcmp(fields, 'fname'))) = [];
                            for fn = fields'
                                val = p.(fn{1});
                                if isnumeric(val)
                                    val = num2str(val);
                                end
                                fname = strcat(fname, '_', fn{1}, '-', val);
                            end
                            p.fname = fname;
                            clear fname
                            param(iStim, iInt, sORNtoORN, sORNtoLNPN, sPN, sLNtoORN, sLNtoLNPN) = p;
                        end
                    end
                end
            end
        end
    end
end

%% Do some stuff to figure out how many batches, runs / batch, and their allocation

% Reshape run parameters so they can be more easily allocated to jobs
paramD = size(param);
param = param(:);
nModels = length(param);

% Set number of runs per job, check to make sure # jobs doesn't exceed set
% number.
nRunsPerJob = 25;
nJobs = ceil(nModels / nRunsPerJob);
if nJobs > 300
    error('Number of jobs to be requested exceeds 300.')
end

% Allocate run indices to job batches
jobBatches = {};
iRunStart = 1:nRunsPerJob:nModels;
for iRun = 1:nJobs
    % Default condition
    if iRun ~= nJobs
        jobBatches{iRun} = iRunStart(iRun):(iRunStart(iRun+1)-1);
    % Since 'last' job will not have a symmetric number of jobs
    elseif iRun == nJobs
        jobBatches{iRun} = iRunStart(iRun):nModels;
    end
end

%% Set job (not run) parameters
memGB = 3;
% timeLimitMin = 4 * nRunsPerJob; % Assuming a max of four minutes per model run
timeLimitMin = 600; % Assuming a max of four minutes per model run
queueName = 'short';
%% Submit job batches
configCluster
c = parcluster;

for iJob = 1:nJobs
    jobName = [d, '_runs_', num2str(jobBatches{iJob}(1)), '-', num2str(jobBatches{iJob}(end))]
    c = set_job_params(c, queueName, timeLimitMin, memGB, jobName);
    inputArgs = {param(jobBatches{iJob}), saveDir};
    c.batch(@batch_run_model_O2, 0, inputArgs)
end

