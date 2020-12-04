param.stimWav = 'square';
param.intensity = 100;
param.baseline = 20;
param.ORNtoORN = 1;
param.ORNtoLNPN = 1;
param.PN = 1;
param.LNtoORN = 1;
param.LNtoLNPN = 1;
param.DepletionRate = 0.3e-3;
param.TauReplenishment = 1e3;
param.fname = '2020-12-04_ORN_mult_DoOR_2-hep_stimWav-square_intensity-100_baseline-20_ORN-1_PN-1_LNtoORN-1_DepletionRate-0.0003_TauReplenishment-1000';

saveDir = '~/Modeling/modeling_results/2020-12-04_testing';


run_model_O2(param, param.fname, saveDir)

load(fullfile(saveDir, [param.fname '.mat']))
%m.plotResults