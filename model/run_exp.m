cd ~/Modeling/modeling_code/model

%% Set # of stimulus conditions
nStim = 3;

%% Request pool of parallel workers
% parpool(6)
%% Run Var stim experiment
nMs = 3;

parfor iM = 1:nMs
    m(iM) = Model();
    m(iM).init();
    m(iM).varStim(iM);
    m(iM).RunTime = size(m(iM).Stimulus, 1);
    m(iM).runExp;
    m(iM).plotResults;
end

%% Run step experiment
intensity = 1;

nMs = 1;
m = Model();
m.init();
m.setIntensity(intensity);
m.runExp;
m.plotResults

%% Parameter sweep
nNs = length(m.KernType);
% This mostly functions off param.scale_type

% Scalar options for changing all weights of given type
scalar.LN = 1;
scalar.PN = 1;
scalar.ORN = 1;

% Scalar options for changing weights between specific types (9 permutations)
scalar.ORNtoPN = 1;
scalar.ORNtoLN = 1;
scalar.ORNtoORN = 1;
scalar.LNtoORN = 1;
scalar.LNtoPN = 1;
scalar.LNtoLN = 1;
scalar.PNtoORN = 1;
scalar.PNtoLN = 1;
scalar.PNtoPN = 1;

% Ugh I hate this but for now I will also have to manually specify the
% indices for each connection type I give. I would love to come up with a
% clever way to do this more arbitrarily.

% Connection indices
ind.LN = {m.TypeInds.ln, 1:nNs};
ind.PN = {m.TypeInds.pn, 1:nNs};
ind.ORN = {m.TypeInds.orn, 1:nNs};

ind.ORNtoPN = {m.TypeInds.orn, m.TypeInds.pn};
ind.ORNtoLN = {m.TypeInds.orn, m.TypeInds.ln};
ind.ORNtoORN = {m.TypeInds.orn, m.TypeInds.orn};
ind.LNtoORN = {m.TypeInds.ln, m.TypeInds.orn};
ind.LNtoPN = {m.TypeInds.ln, m.TypeInds.pn};
ind.LNtoLN = {m.TypeInds.ln, m.TypeInds.ln};
ind.PNtoORN = {m.TypeInds.pn, m.TypeInds.orn};
ind.PNtoLN = {m.TypeInds.pn, m.TypeInds.ln};
ind.PNtoPN = {m.TypeInds.pn, m.TypeInds.pn};



% Get 'scalar' fieldnames
fields = fieldnames(scalar);

% Adjust adjacency matrix weights 
for fn = fields'
    if scalar.(fn{1}) ~= 1
        % Be careful, it is possible to double scale certain connections.
        % e.g., scaling both 'scalar.LN' and 'scalar.LNtoPN'
        m.AdjMat = scale_type(m.AdjMat, scalar.(fn{1}), ind.(fn{1}));
    end
end

 
% LNtoPNScalar = 0.0; % values <1 weaken the effect of postsynaptic inhibition onto PNs
% LNtoLNScalar = 0.05; % values <1 weaken the effect of postsynaptic inhibition onto LNs
% PNtoLNScalar = 0.05; % values <1 weaken the effect of PN->LN connections
% ORNtoAllScalar = 0.01; % Rachel called this 'ReleaseImpactScalar'
% LNtoORNScalar = 0.01;  % Rachel called this 'preInhibitionscalar'
% % 
% 
% adjMat(typeInds.ln, typeInds.pn) = adjMat(typeInds.ln, typeInds.pn) * LNtoPNScalar;
% adjMat(typeInds.ln, typeInds.ln) = adjMat(typeInds.ln, typeInds.ln) * LNtoLNScalar;
% adjMat(typeInds.pn, typeInds.ln) = adjMat(typeInds.pn, typeInds.ln) * PNtoLNScalar;
% adjMat(typeInds.orn, :) = adjMat(typeInds.orn, :) * ORNtoAllScalar;
% adjMat(typeInds.ln, typeInds.orn) = adjMat(typeInds.ln, typeInds.orn) * LNtoORNScalar;
% 
% % adjMat(typeInds.ln, :) = adjMat(typeInds.ln, :) * 0.6;
% adjMat(typeInds.orn, typeInds.orn) = 0;
% adjMat(typeInds.pn, typeInds.orn) = 0;
% 
% adjMat(typeInds.pn, typeInds.pn) = 0;
% adjMat([typeInds.orn, typeInds.pn], typeInds.orn) = 0;

% adjMat(2:end, typeInds.orn) = adjMat(2:end, typeInds.orn) * 0.5;
