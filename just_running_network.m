%% Run the trial. All values are calculated one step at a time using the
% forward euler method.
for timeStep = (kernLen + 1):runTime
    for iN = 2:length(nn)
        iDep = isDep(:,iN);
        inputActivity(iDep, timeStep-1) = networkRelease(iDep, timeStep-1);
        inputActivity(~iDep, timeStep-1) = networkFR(~iDep, timeStep-1);
        
        % Calculate linear responses (Vm)
        nn(iN).calcResponses(inputActivity, timeStep, ~isDiv(:, iN));
        nn(iN).rectify(timeStep);
        nn(iN).Rel(timeStep) = nn(iN).FR(timeStep);
        
        nn(iN).divInhibition(networkActivity, timeStep, isDiv(:, iN));
        nn(iN).calcResources(timeStep);
        
        nn(iN).Rel(timeStep) = nn(iN).Rel(timeStep) * nn(iN).SynRes(timeStep);
        networkFR(iN, timeStep) = nn(iN).FR(timeStep); 
        networkRelease(iN, timeStep) = nn(iN).Rel(timeStep); 
    end
end
% for iN = 2:length(nn)
%     networkActivity(iN, :) = nn(iN).FR;
% end
networkActivity = inputActivity;