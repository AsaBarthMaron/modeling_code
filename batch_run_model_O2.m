function batch_run_model_02(param, saveDir)

nRuns = length(param);
fname = extractfield(param, 'fname');
param = rmfield(param, 'fname');

for iRun = 1:nRuns
    run_model_O2(param(iRun), fname(iRun), saveDir);
end

end