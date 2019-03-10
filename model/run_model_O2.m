function run_model_O2(stimWav, intensity, saveDir)

%   stimWav
%   intensities
%   varargin not being used for now

args.stimWav = stimWav;
args.intensity = intensity;

fields = fieldnames(args);
argString = [];
for fn = fields'
    val = args.(fn{1});
    if isnumeric(val)
        val = num2str(val);
    end
    argString = strcat(argString, '_', fn{1}, '-', val);
end

m = Model();
m.init();   % This works for now only because we're not yet playing with 
            % changes to model parameters. Otherwise the normalization &
            % scaling done in .init() would be problematic.
m.setStimulus(stimWav);
m.setIntensity(intensity);
m.addBaseline();
m.runExp();
m.saveResults(saveDir);

end

% p = inputParser;
% p.addOptional('stimWav', 'square');
% p.addOptional('intensity', 100);
% p.parse(stimWav, intensity);
% 
% % Create argString for use in help creating a unique and informative
% % filename.
% fields = fieldnames(p.Results);
% argString = ['_'];
% 
% for fn = fields'
%     val = p.Results.(fn{1});
%     if isnumeric(val)
%         val = num2str(val);
%     end
%     argString = strcat(argString, fn{1}, '_', val);
%     clear val
% end
