% Decide if this will be a function or script

clear
addpath(genpath('~/Modeling/modeling_code/'));
saveDir="~/Modeling/modeling_results/2019-04-11_parameter_sweep_filename_test"
if ~isdir(saveDir)
    mkdir(saveDir)
end

%% Create parameter combinations

% intensities = [1, 10, 100, 1000];
intensities = [100, 100, 1e3, 1e4];

% stimWaveforms = {'fast', 'med', 'slow', 'steps', 'square'};
% stimWaveforms = {'fast', 'med', 'slow', 'square'};
stimWaveforms = {'square'};

% scalarSteps = [0, 1, 10, 100];
scalarSteps = [0, 0.1, 1];
% scalarSteps = [0, 0.1, 1, 5, 10];
nScalarSteps = length(scalarSteps);

%% Set model parameters
d = datetime('now', 'format', 'yyyy-MM-dd');
d = char(d);

for iStim = 1%:length(stimWaveforms)
    for iInt = 1%1:length(intensities)
        for sORN = 1:nScalarSteps
            for sPN = 1:nScalarSteps
                for sLN = 1:nScalarSteps
                    for sLNtoORN = 1:nScalarSteps
                        for sLNtoLNPN = 1:nScalarSteps
                            p.stimWav = stimWaveforms{iStim};
                            p.intensity = intensities(iInt);
                            p.ORN = scalarSteps(sORN);
                            p.PN = scalarSteps(sPN);
                            p.LN = scalarSteps(sLN);
                            p.LNtoORN = scalarSteps(sLNtoORN);
                            p.LNtoLNPN = scalarSteps(sLNtoLNPN);
                            p.fname = [];
                            
%                             param(iStim, iInt, sORN, sPN, sLN, sLNtoORN, sLNtoLNPN)...
%                                 .stimWaveform = stimWaveforms(iStim);
%                             param(iStim, iInt, sORN, sPN, sLN, sLNtoORN, sLNtoLNPN)...
%                                 .intensity = intensities(iInt);
%                             param(iStim, iInt, sORN, sPN, sLN, sLNtoORN, sLNtoLNPN)...
%                                 .ORN = scalarSteps(sORN);
%                             param(iStim, iInt, sORN, sPN, sLN, sLNtoORN, sLNtoLNPN)...
%                                 .PN = scalarSteps(sPN);
%                             param(iStim, iInt, sORN, sPN, sLN, sLNtoORN, sLNtoLNPN)...
%                                 .LN = scalarSteps(sLN);
%                             param(iStim, iInt, sORN, sPN, sLN, sLNtoORN, sLNtoLNPN)...
%                                 .LNtoORN = scalarSteps(sLNtoORN);
%                             param(iStim, iInt, sORN, sPN, sLN, sLNtoORN, sLNtoLNPN)...
%                                 .LNtoLNPN = scalarSteps(sLNtoLNPN);
                            
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
                            param(iStim, iInt, sORN, sPN, sLN, sLNtoORN, sLNtoLNPN) = p;
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
nRunsPerJob = 100;
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
memGB = 2;
% timeLimitMin = 4 * nRunsPerJob; % Assuming a max of four minutes per model run
timeLimitMin = 360; % Assuming a max of four minutes per model run
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

