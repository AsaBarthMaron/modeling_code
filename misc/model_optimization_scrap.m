%% Original
tmpTimer = tic;
duration = 0; 

    leadTime = toc(tmpTimer);
    iDep = isDep(:,iN);
    inputActivity(iDep, timeStep-1) = networkRelease(iDep, timeStep-1);
    inputActivity(~iDep, timeStep-1) = networkFR(~iDep, timeStep-1);
    disp(['Var managing - ' num2str(toc(tmpTimer) - leadTime)])
        
    % Add noise to all input activity for this timestep
    inputActivity(:, timeStep-1) = inputActivity(:, timeStep-1) + noise(:, timeStep-1);
    %         inputActivity(iActivityInj, timeStep-1) = inputActivity(iActivityInj, timeStep-1) + 100;
    
    leadTime = toc(tmpTimer);
    nn(iN).calcResponses(inputActivity, timeStep, ~isDiv(:, iN));
    disp(['calcResponses - ' num2str(toc(tmpTimer) - leadTime)])

    leadTime = toc(tmpTimer);
    nn(iN).rectify(timeStep);
    disp(['rectify - ' num2str(toc(tmpTimer) - leadTime)])
    
    leadTime = toc(tmpTimer);
    nn(iN).Rel(timeStep) = nn(iN).FR(timeStep);
    disp(['Rel - ' num2str(toc(tmpTimer) - leadTime)])

    leadTime = toc(tmpTimer);
    nn(iN).divInhibition(inputActivity, timeStep, isDiv(:, iN));
    disp(['divInhibition - ' num2str(toc(tmpTimer) - leadTime)])
    
    leadTime = toc(tmpTimer);
    nn(iN).calcResources(timeStep);
    disp(['calcResources - ' num2str(toc(tmpTimer) - leadTime)])

   leadTime = toc(tmpTimer);
    nn(iN).Rel(timeStep) = nn(iN).Rel(timeStep) * nn(iN).SynRes(timeStep);
    networkFR(iN, timeStep) = nn(iN).FR(timeStep); 
    networkRelease(iN, timeStep) = nn(iN).Rel(timeStep); 
    tTic(iN, timeStep) = toc(startTic);
    disp(['More var managing - ' num2str(toc(tmpTimer) - leadTime)])
toc(tmpTimer)
%% Modifications
tmpTimer = tic;
duration = 0; 

    leadTime = toc(tmpTimer);
    iDep = isDep(:,iN);
    inputActivity(iDep, timeStep-1) = networkRelease(iDep, timeStep-1);
    inputActivity(~iDep, timeStep-1) = networkFR(~iDep, timeStep-1);
    disp(['Var managing - ' num2str(toc(tmpTimer) - leadTime)])
        
    % Add noise to all input activity for this timestep
    inputActivity(:, timeStep-1) = inputActivity(:, timeStep-1) + noise(:, timeStep-1);
    %         inputActivity(iActivityInj, timeStep-1) = inputActivity(iActivityInj, timeStep-1) + 100;
    
    leadTime = toc(tmpTimer);
    nn(iN).calcResponses(inputActivity, timeStep, ~isDiv(:, iN));
    disp(['calcResponses - ' num2str(toc(tmpTimer) - leadTime)])

    leadTime = toc(tmpTimer);
    nn(iN).rectify(timeStep);
    disp(['rectify - ' num2str(toc(tmpTimer) - leadTime)])
    
    leadTime = toc(tmpTimer);
    nn(iN).Rel(timeStep) = nn(iN).FR(timeStep);
    disp(['Rel - ' num2str(toc(tmpTimer) - leadTime)])

    leadTime = toc(tmpTimer);
    nn(iN).divInhibition(inputActivity, timeStep, isDiv(:, iN));
    disp(['divInhibition - ' num2str(toc(tmpTimer) - leadTime)])
    
    leadTime = toc(tmpTimer);
    nn(iN).calcResources(timeStep);
    disp(['calcResources - ' num2str(toc(tmpTimer) - leadTime)])

   leadTime = toc(tmpTimer);
    nn(iN).Rel(timeStep) = nn(iN).Rel(timeStep) * nn(iN).SynRes(timeStep);
    networkFR(iN, timeStep) = nn(iN).FR(timeStep); 
    networkRelease(iN, timeStep) = nn(iN).Rel(timeStep); 
    tTic(iN, timeStep) = toc(startTic);
    disp(['More var managing - ' num2str(toc(tmpTimer) - leadTime)])
toc(tmpTimer)