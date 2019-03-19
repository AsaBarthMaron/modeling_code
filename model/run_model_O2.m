function run_model_O2(param, fname, saveDir)

%   stimWav
%   intensities
%   varargin not being used for now

%   For now (3/19/19:
%   ORN         % Should not be done in combination with ORNtoLNPN, ORN-ORN
%   PN          % Should not be done in combination with PNtoLNPN, PN-ORN
%   LN          % Should not be done in combination with LNtoLNPN, LN-ORN
%   LNtoORN
%   LNtoLNPN

scalar = struct;
scalar.ORN = param.ORN;        % Should not be done in combination with ORNtoLNPN, ORN-ORN
scalar.PN = param.PN;          % Should not be done in combination with LNtoLNPN, LN-ORN
scalar.LN = paramLN;          % Should not be done in combination with LNtoLNPN, LN-ORN
scalar.LNtoORN = param.LNtoORN;
scalar.LNtoLNPN = param.LNtoLNPN;

m = Model();
m.init();   % This works for now only because we're not yet playing with 
            % changes to model parameters. Otherwise the normalization &
            % scaling done in .init() would be problematic.
            % 3/13/19 - Actually I want to do param tweaking after the
            % normalization and scaling.
scale_cons(m, scalar);
m.setStimulus(stimWav);
m.setIntensity(intensity);
m.addBaseline();
m.runExp();
m.saveResults(argString, saveDir);

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
