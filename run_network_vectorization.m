%% 
nA = zeros(nNeurons, runTime);
T = nn(2).TauKrn';
iDep = isDep(:,2);
startTic = tic;
tTic = zeros(nNeurons, runTime);
for timeStep = (kernLen + 1):runTime
    linMat = adjMat;
    linMat(isDep) = 0; % In theory we could just index the ~isDep during 
                       % the linear operations below, which would certainly
                       % be faster. However the only way I can think to do
                       % that requires the assumption that neurons are all
                       % or none in terms of whether their outputs deplete.

    
    nA(:, timeStep - 1) = nA(:, (timeStep - kernLen):(timeStep-1)) * T;
    
    nA(:, timeStep) = linMat' * nA(:, timeStep - 1);
    
    % Okay now lets calculate responses for the nonlinear units. This is
    % also assuming that ORNs are unique in that they are the only ones
    % which receive divisive inhibition. 
    
    for iN = 2:nNeurons
        
    end
end

%% Run the trial. All values are calculated one step at a time using the
% forward euler method.
timing = zeros(runTime, 1);
startTic = tic;
tTic = zeros(nNeurons, runTime);
for timeStep = (kernLen + 1):runTime
    iDep = isDep(:,iN);
    inputActivity(iDep, timeStep-1) = networkRelease(iDep, timeStep-1);
    inputActivity(~iDep, timeStep-1) = networkFR(~iDep, timeStep-1);
    
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

    if timeStep == 1200
%         pause
    end
%     timing(timeStep) = toc(startTic);
end
toc(startTic)
% for iN = 2:length(nn)
%     networkActivity(iN, :) = nn(iN).FR;
% end
networkActivity = inputActivity;
%% Run the trial. All values are calculated one step at a time using the
% forward euler method.
timing = zeros(runTime, 1);
startTic = tic;
tTic = zeros(nNeurons, runTime);
for timeStep = (kernLen + 1):runTime
    iDep = isDep(:,2); % Changed, now assumes all outputs of neuron are either depleting or not
    inputActivity(iDep, timeStep-1) = networkRelease(iDep, timeStep-1);
    inputActivity(~iDep, timeStep-1) = networkFR(~iDep, timeStep-1);

    for iN = 2:length(nn)

        % Add noise to all input activity for this timestep
%         inputActivity(:, timeStep-1) = inputActivity(:, timeStep-1) + noise(:, timeStep-1);
%         inputActivity(iActivityInj, timeStep-1) = inputActivity(iActivityInj, timeStep-1) + 100;
        
        nn(iN).calcResponses(inputActivity, timeStep, ~isDiv(:, iN));
        nn(iN).rectify(timeStep);
        nn(iN).Rel(timeStep) = nn(iN).FR(timeStep);
        
        nn(iN).divInhibition(inputActivity, timeStep, isDiv(:, iN));
        nn(iN).calcResources(timeStep);
        
        nn(iN).Rel(timeStep) = nn(iN).Rel(timeStep) * nn(iN).SynRes(timeStep);
        networkFR(iN, timeStep) = nn(iN).FR(timeStep); 
        networkRelease(iN, timeStep) = nn(iN).Rel(timeStep); 
        tTic(iN, timeStep) = toc(startTic);

    end
    if timeStep == 1200
%         pause
    end
%     timing(timeStep) = toc(startTic);
end
toc(startTic)
% for iN = 2:length(nn)
%     networkActivity(iN, :) = nn(iN).FR;
% end
networkActivity = inputActivity;