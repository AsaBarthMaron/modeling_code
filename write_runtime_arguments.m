%% write_runtime_arguments.m generates .txt file that will specify batch model arguments.
% 

% This works for linearly spaced variables, but should also extend to
% log scale.

fname = '2019-03-11_steps_debugging.txt';
saveDir = '~/Modeling/modeling_results/runtime_arguments'
intensityStepSize = 100;
intensityRange = [0 1e3];
intensities = [intensityRange(1):intensityStepSize:intensityRange(2)];

% scalarStepSize = 0.1;
% scalarStepRange = [0.1, 2];
% scalarSteps = [scalarStepRange(1):scalarStepSize:scalarStepRange(2)];

stimWaveforms = {'fast', 'med', 'slow', 'steps', 'square'};

fid = fopen(fullfile(saveDir, fname), 'w');

for stim = 1 %stimWaveforms
    for int = 384 %intensities
        fprintf(fid, '%10s, %6.2f\n', 'steps', int)
    end
end
fprintf(fid, ',');

fclose(fid);