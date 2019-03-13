%% write_runtime_arguments.m generates .txt file that will specify batch model arguments.
% 

% This works for linearly spaced variables, but should also extend to
% log scale.

fname = '2019-03-13_minimal_con_type_param_sweep.txt';
saveDir = '~/Modeling/modeling_results/runtime_arguments';
% intensityStepSize = 100;
% intensityRange = [0 1e3];
% intensities = [intensityRange(1):intensityStepSize:intensityRange(2)];
intensities = [1, 10, 100, 1000];

% stimWaveforms = {'fast', 'med', 'slow', 'steps', 'square'};
% stimWaveforms = {'fast', 'med', 'slow', 'square'};
stimWaveforms = {'square'};

%% Set connection type scalars
% scalarStepSize = 0.1;
% scalarStepRange = [0.1, 2];
% scalarSteps = [scalarStepRange(1):scalarStepSize:scalarStepRange(2)];
scalarSteps = [0, 1, 10, 100];

% Adjust adjacency matrix weights 
  scalar = struct;
  scalar.ORNtoLNPN = 1;
  scalar.PNtoLNPN = 1;
  scalar.LNtoLNPN = 1;
  scalar.ORNtoORN = 1;
  scalar.LNtoORN = 1;
  scalar.PNtoORN = 1;
  scalar.ORN = 1;         % Should not be done in combination with ORNtoLNPN, ORN-ORN
  scalar.LN = 1;          % Should not be done in combination with LNtoLNPN, LN-ORN
  scalar.PN = 1; 
  
  fields = fieldnames(scalar);

%% Write to file
fid = fopen(fullfile(saveDir, fname), 'w');

for stim = stimWaveforms
    for int = intensities
        for fn = fields'
            for s = scalarSteps
                scalar.(fn{1}) = s;
                fprintf(fid, '%10s, %6.2f', stim{1}, int)

                for iField = 1:length(fields)
                    fprintf(fid, ', %5d', scalar.(fields{iField}));
                end
                fprintf(fid, '\n')
                scalar.(fn{1}) = 1;
            end
        end
    end
end
fprintf(fid, ',');

fclose(fid);

% function scaleCons(m, scalar)
% %   scalar.ORNtoLNPN
% %   scalar.PNtoLNPN
% %   scalar.LNtoLNPN
% %   scalar.ORNtoORN
% %   scalar.LNtoORN
% %   scalar.PNtoORN
% %   scalar.ORN         % Should not be done in combination with ORNtoLNPN, ORN-ORN
% %   scalar.LN          % Should not be done in combination with LNtoLNPN, LN-ORN
% %   scalar.PN          % Should not be done in combination with PNtoLNPN, PN-ORN
% 
% nNs = length(m.KernType);
% % This mostly functions off param.scale_type
% 
% % Connection indices
% ind.ORNtoLNPN = {m.TypeInds.orn, [m.TypeInds.ln, m.TypeInds.pn]};
% ind.PNtoLNPN = {m.TypeInds.pn, [m.TypeInds.ln, m.TypeInds.pn]};
% ind.ORNtoLNPN = {m.TypeInds.ln, [m.TypeInds.ln, m.TypeInds.pn]};
% ind.ORNtoORN = {m.TypeInds.orn, m.TypeInds.orn};
% ind.LNtoORN = {m.TypeInds.ln, m.TypeInds.orn};
% ind.PNtoORN = {m.TypeInds.pn, m.TypeInds.orn};
% ind.LN = {m.TypeInds.ln, 1:nNs};
% ind.PN = {m.TypeInds.pn, 1:nNs};
% ind.ORN = {m.TypeInds.orn, 1:nNs};
% 
% 
% % Get 'scalar' fieldnames
% fields = fieldnames(scalar);
% 
% % Adjust adjacency matrix weights 
% for fn = fields'
%     if scalar.(fn{1}) ~= 1
%         % Be careful, it is possible to double scale certain connections.
%         % e.g., scaling both 'scalar.LN' and 'scalar.LNtoPN'
%         m.AdjMat = scale_type(m.AdjMat, scalar.(fn{1}), ind.(fn{1}));
%     end
% end
% end
% 
%  