function networkActivity = run_network_working(adjMat, neuronLabels, inhbCon, divCon, depCon, facCon, taus, kernType, stimulus)
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
    nn(iN).IntegratedFR = zeros(nn(iN).NSteps, 1);
end

% Set synaptic properties for specific connections. Logical matrices for
% all connections. Why am I doing this and not just passing in logical
% matrices for each thing? 
isInhb = false(nNeurons, nNeurons); % Currently this info is already present in adjMat, so it is not being used.
isDiv = false(nNeurons, nNeurons);
isDep = false(nNeurons, nNeurons);
isFac = false(nNeurons, nNeurons);

% Some fancy indexing to use ordered pairs to assign corresponding values
% in logical matrices to 1
isInhb(sub2ind(size(isInhb), inhbCon(:,1), inhbCon(:,2))) = 1;
isDiv(sub2ind(size(isDiv), divCon(:,1), divCon(:,2))) = 1;
isDep(sub2ind(size(isDep), depCon(:,1), depCon(:,2))) = 1;

% Doesn't yet work, or do anything
% isFac(sub2ind(size(isFac), facCon(:,1), facCon(:,2))) = 1;

% isInhb = logical(inhbCon);
% isDiv = logical(divCon);
% isDep = logical(depCon);
% isFac = logical(facCon);

% Matrix for holding network activity values
inputActivity = ones(length(nn), runTime);
inputActivity(1, :) = stimulus;
networkFR = inputActivity;
networkRelease = inputActivity;
networkActivity = inputActivity;
%% Run the trial. All values are calculated one step at a time using the
% forward euler method.
for timeStep = (kernLen + 1):runTime
    for iN = 2:length(nn)
        iDep = isDep(:,iN);
        inputActivity(iDep, timeStep-1) = networkRelease(iDep, timeStep-1);
        inputActivity(~iDep, timeStep-1) = networkFR(~iDep, timeStep-1);
        nn(iN).calcResponses(inputActivity, timeStep, isDiv(:, iN));
        nn(iN).rectify(timeStep);
        nn(iN).calcResources(timeStep);
        nn(iN).Rel(timeStep) = nn(iN).FR(timeStep) * nn(iN).SynRes(timeStep);
        networkFR(iN, timeStep) = nn(iN).FR(timeStep); 
        networkRelease(iN, timeStep) = nn(iN).Rel(timeStep); 
    end
end
% for iN = 2:length(nn)
%     networkActivity(iN, :) = nn(iN).FR;
% end
networkActivity = inputActivity;
%%
yLims(2) = max(max(networkActivity(2:end, 1000:end)));
yLims(2) = yLims(2) * 1.5;
yLims(1) = 0;
a(1, :) = networkActivity(1,:);
networkActivity(1,:) = ((networkActivity(1,:) / max(networkActivity(1,:))) * yLims(2)/10) + (0.8 * yLims(2));
figure
plot(1000:runTime, networkActivity(:,1000:end)', 'linewidth', 2)
ylim = yLims;
legend(neuronLabels, 'location', 'west')
set(gca, 'box', 'off', 'fontsize', 20, 'ylim', yLims)
% axis([0 1000 0 10])
set(gcf, 'position', [0 0 1920 1200])
% set(gcf, 'position', [0 0 960 600])