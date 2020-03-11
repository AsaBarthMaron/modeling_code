function [networkActivity, nn] = run_network(adjMat, neuronLabels, isDep, isDiv, isFac, taus, kernType, stimulus, iActivityInj, DepletionRate, TauReplenishment)
% RUN_NETWORK creates a network and runs it for a single trial condition

% Input parameters -
%     adjMat:         Adjacency matrix of connection strengths. First entry
%                     (row/column) should be the stimulus connections.
%                     Which should just be to ORN(s).
%     neuronLabels:   Neuron names
%     inhbCon:        Ordered pairs identifying which connections are 
%                     inhibitory
%     divCon:         Ordered pairs of divisive connections. Default is 
%                     subtractive
%     depCon:         Ordered pairs of connections that have synaptic
%                     depletion
%     facCon:         Orderd pairs of connections that have synaptic
%                     facilitation
%     taus:           Vector of time constants for each neuron
%     kernType:       'exp' - exponential, 'alpha' - alpha fn
%     stimulus:       Stimulus vector. Stimulus obj Rel prop. 

%% Initialize and set timing variables
sampRate = 1000; % 1000 samples/s. Should not change. 
stepSize = (1 / sampRate) * 1e3; % Size (in ms) of each time step

timeStep = 1;   % Sample at which to initialize model
runTime = length(stimulus); % Model run time (in samples)

%% Construct network

nNeurons = length(neuronLabels);
kernLen = 300;  % Length of kernel for endowing response dynamics. Note 
                % that these kernels reflect a combination of membrane, 
                % spiking, and synaptic dynamics.
                
% Instantiate Neuron class for each neuron in network. Typically Neuron #1
% will be the stimulus.
for iN = 1:nNeurons
    nn(iN) = Neuron();
end
   
% Set obj properties
for iN = 1:length(nn)
    nn(iN).Name = neuronLabels{iN};
    nn(iN).TimeStep = timeStep;
    nn(iN).StepSize = stepSize; 
    nn(iN).RunTime = runTime;
    nn(iN).NSteps = nn(iN).RunTime ./ nn(iN).StepSize;
    nn(iN).Tau = taus(iN);
    
    % Calculate appropriate kernels
    switch kernType{iN}
        case 'exp'
            nn(iN).TauKrn = exp(-(1:kernLen)/nn(iN).Tau);
        case 'alpha'
            nn(iN).TauKrn = (1:kernLen) .* exp(-(1:kernLen)/nn(iN).Tau);
        otherwise 
            disp('Please enter a valid kernel type')
    end
    nn(iN).TauKrn = fliplr(nn(iN).TauKrn);
    nn(iN).TauKrn = nn(iN).TauKrn ./ sum(nn(iN).TauKrn);
    
    nn(iN).Inputs = adjMat(:,iN);
    
    % Vm FR and Rel (and similarly networkActivity below are set to 1
    % (spk/s) to prevent keep divisive inhibition within a regime that
    % makes sense mathematically. 
    nn(iN).Vm = ones(nn(iN).NSteps, 1);
    nn(iN).FR = ones(nn(iN).NSteps, 1);
    nn(iN).Rel = ones(nn(iN).NSteps, 1);
    nn(iN).SynRes = ones(nn(iN).NSteps, 1); % Value between 0 and 1
end

for iN = 2:3
    nn(iN).DepletionRate = DepletionRate;
    nn(iN).TauReplenishment = TauReplenishment;
end

% Set synaptic properties for specific connections. Logical matrices for
% all connections. Why am I doing this and not just passing in logical
% matrices for each thing? 
% isDiv = false(nNeurons, nNeurons);
% isDep = false(nNeurons, nNeurons);
% isFac = false(nNeurons, nNeurons);

% Create a noise matrix
rng(1)
cn = dsp.ColoredNoise('Color','white','NumChannels', nNeurons, 'SamplesPerFrame',runTime);
noise = cn()' * 0.35;

% Matrix for holding network activity values
inputActivity = ones(length(nn), runTime);
inputActivity(1, :) = stimulus;
% inputActivity(1,:) = inputActivity(1,:) + noise(1,:);

networkFR = inputActivity;
networkRelease = inputActivity;
networkActivity = inputActivity;


% Design activity vector for activity injection
injMag = 1000;   % Free parameter
activityInj = normalize(stimulus, 'range') * injMag;

%% Run the trial. All values are calculated one step at a time using the
% forward euler method.
timing = zeros(runTime, 1);
startTic = tic;
tTic = zeros(nNeurons, runTime);

loadInitialCond = 0;
if loadInitialCond
    iC = load('/Users/asa/Modeling/2018-12-27_modeling/model4_initial_conditions.mat');
    networkFR(:, 1:kernLen) =  iC.networkFR(:,(end-kernLen+1):end);
    networkRelease(:, 1:kernLen) =  iC.networkRelease(:,(end-kernLen+1):end);
    inputActivity(:, 1:kernLen) =  iC.inputActivity(:,(end-kernLen+1):end);

    for iN = 1:nNeurons
        nn(iN).FR = networkFR(iN,:);
    end
    for iN = 2:3 % Manually set right now to ORN indices, needs to change if ORN population changes
        nn(iN).Rel = networkRelease(iN,:);
        nn(iN).SynRes(1:kernLen) = iC.synRes(iN-1,(end-kernLen+1):end); % Also assumes certain ORN indices are hard coded
    end
end
    
for timeStep = (kernLen + 1):runTime
    

    
    iDep = isDep(:,2);
    inputActivity(iDep, timeStep-1) = networkRelease(iDep, timeStep-1);
    inputActivity(~iDep, timeStep-1) = networkFR(~iDep, timeStep-1);
   
    if timeStep == 2522
        x = 1;
    end
    % Add noise to all input activity for this timestep
%     inputActivity(:, timeStep-1) = inputActivity(:, timeStep-1) + noise(:, timeStep-1);
%     inputActivity(iActivityInj, timeStep-1) = inputActivity(iActivityInj, timeStep-1) + 100;
    
    for iN = 2:length(nn)
        nn(iN).calcResponses(inputActivity, timeStep, ~isDiv(:, iN));
        nn(iN).rectify(timeStep);
        networkFR(iN, timeStep) = nn(iN).FR(timeStep); 
    end
    for iN = 2:3
        nn(iN).Rel(timeStep) = nn(iN).FR(timeStep);
        nn(iN).divInhibition(inputActivity, timeStep, isDiv(:, iN));
        nn(iN).calcResources(timeStep);
        nn(iN).Rel(timeStep) = nn(iN).Rel(timeStep) * nn(iN).SynRes(timeStep);
        networkRelease(iN, timeStep) = nn(iN).Rel(timeStep); 
%         tTic(iN, timeStep) = toc(startTic);
    end
    
    % Inject activity into subset of neurons
    % Note, that I am only injecting into networkFR, not nn(iN).FR, but
    % this shouldn't matter except for the first sample because networkFR
    % is used to calculate nn.(iN).FR for all future timesteps.
    networkFR(iActivityInj, timeStep) = networkFR(iActivityInj, timeStep) + activityInj(timeStep);
    
%     timing(timeStep) = toc(startTic);
end
toc(startTic)
% for iN = 2:length(nn)
%     networkActivity(iN, :) = nn(iN).FR;
% end
networkActivity = inputActivity;
%%
% networkActivity(2:3,:) = networkFR(2:3,:);
