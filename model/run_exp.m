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