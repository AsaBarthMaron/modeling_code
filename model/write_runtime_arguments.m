%% write_runtime_arguments.m generates .txt file that will specify batch model arguments.
% 

% This works for linearly spaced variables, but should also extend to
% log scale.

cd '~/Modeling/modeling_code/model'
intensityStepSize = 100;
intensityRange = [0 1e3];
intensities = [intensityRange(1):intensityStepSize:intensityRange(2)];

% scalarStepSize = 0.1;
% scalarStepRange = [0.1, 2];
% scalarSteps = [scalarStepRange(1):scalarStepSize:scalarStepRange(2)];

stimWaveforms = {'fast', 'med', 'slow', 'steps', 'square'};

fname = '2019-03-08_first_run.txt';
fid = fopen(fname, 'w');

for stim = stimWaveforms
    for int = intensities
        fprintf(fid, '%10s, %6.2f\n', stim{1}, int)
    end
end
fprintf(fid, ',');

fclose(fid);