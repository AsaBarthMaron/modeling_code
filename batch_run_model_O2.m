function batch_run_model_O2(param, saveDir)

disp('Starting job')
nRuns = length(param);
fname = extractfield(param, 'fname');
param = rmfield(param, 'fname');

for iRun = 1:nRuns
    run_model_O2(param(iRun), fname(iRun), saveDir);
end
disp('Job finished')

end
