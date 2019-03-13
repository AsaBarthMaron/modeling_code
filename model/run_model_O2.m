function run_model_O2(stimWav, intensity, ORNtoLNPN, PNtoLNPN, LNtoLNPN, ORNtoORN, LNtoORN, PNtoORN, ORN, LN, PN, saveDir)

%   stimWav
%   intensities
%   varargin not being used for now

%   For now (3/12/19) add:
%   ORNtoLNPN
%   PNtoLNPN
%   LNtoLNPN
%   ORNtoORN
%   LNtoORN
%   PNtoORN
%   ORN         % Should not be done in combination with ORNtoLNPN, ORN-ORN
%   LN          % Should not be done in combination with LNtoLNPN, LN-ORN
%   PN          % Should not be done in combination with PNtoLNPN, PN-ORN
%   lnTau

args.stimWav = stimWav;
args.intensity = intensity;

scalar = struct;
scalar.ORNtoLNPN = ORNtoLNPN;
scalar.PNtoLNPN = PNtoLNPN;
scalar.LNtoLNPN = LNtoLNPN;
scalar.ORNtoORN = ORNtoORN;
scalar.LNtoORN = LNtoORN;
scalar.PNtoORN = PNtoORN;
scalar.ORN = ORN;        % Should not be done in combination with ORNtoLNPN, ORN-ORN
scalar.LN = LN;          % Should not be done in combination with LNtoLNPN, LN-ORN
scalar.PN = PN;          % Should not be done in combination with LNtoLNPN, LN-ORN

fields = fieldnames(scalar);
for fn = fields'
    args.(fn{1}) = scalar.(fn{1});
end

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
