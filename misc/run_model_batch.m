%% run_model_batch - High level control script for running model batches
% 

% This works for linearly spaced variables, but should also extend to
% log scale.
intensityStepSize = 100;
intensityRange = [0 1e3];
intensities = [intensityRange(1):intensityStepSize:intensityRange(2)];

scalarStepSize = 0.1;
scalarStepRange = [0.1, 2];
scalarSteps = [scalarStepRange(1):scalarStepSize:scalarStepRange(2)];

nModels = intensityStepSize * scalarStepSize;

for i

for 
nMs = 1;
m = Model();
m.init();
m.setIntensity(intensity);
m.runExp;
m.plotResults
