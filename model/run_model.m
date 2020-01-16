load('/Users/asa/2018-12-14_full_LN_adj_mat/2018-12-15_input_vars.mat')
cd /Users/asa/Modeling/modeling_code/model

remLNs = iLNs;
remLNs([typeInds.y; typeInds.ts; typeInds.d]) = [];
typeInds.rem = remLNs;
%% Create stimulus                
stimIncrement = 1.5;
baseline = ones(2000, 1)*10;
StimulusOnset = length(baseline);
stimulus = baseline;
    
stimLvls = stimIncrement * (2.^[1:8]);
stimLvls = stimLvls + max(baseline);

for i = 1:8
    stimSegment = zeros(100, 1) + stimLvls(i);
    stimulus = [stimulus;stimSegment];
end
stimulus = stimulus + 10;
%% Connection type specific scaling
adjMat(2:end, 2:end) = adjMat(2:end, 2:end) ./ sum(abs(adjMat(2:end,2:end)), 1);
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

tic
adjMat(2:end, 2:end) = adjMat(2:end, 2:end) * 10;

%% Model perturbations
% Here we can set certain synape values to zero, or other synapse strength
% specific manipulation. If we want to inject positive or negative activity
% we will have to do that within 'run_network.m' or create a way to pass
% that in.
% adjMat(iLNs(typeInds.y), iLNs(typeInds.y)) = 0;

silenceY = 0;
silenceTS = 0;
silenceD = 0;

if silenceY
    adjMat(iLNs(typeInds.y), :) = 0;
end
if silenceTS
    adjMat(iLNs(typeInds.ts), :) = 0;
end
if silenceD
    adjMat(iLNs(typeInds.d), :) = 0;
end
% adjMat(typeInds.rem, :) = 0;
%% Run the model
% adjMat(1,3) = 0.5;
[networkActivity, nn] = run_network(adjMat, neuronLabels, isDep, isDiv, isFac, taus, kernType, stimulus, iLNs(typeInds.y), 0.3 * 1e-3, 1e3);


%%
xStart = 1000;
networkActivity(:, end) = networkActivity(:, end-1);
runTime = length(stimulus);
yLims(2) = max(max(networkActivity(4:end, xStart:end)));
yLims(2) = yLims(2) * 1.05;
yLims(1) = 0;
xLims = [xStart runTime];
a(1, :) = networkActivity(1,:);
% networkActivity(1,:) = ((networkActivity(1,:) / max(networkActivity(1,:))) * yLims(2)/10) + (0.8 * yLims(2));
% networkActivity(2,:) = ((networkActivity(2,:) / max(networkActivity(2,:))) * yLims(2)/10) + (0.8 * yLims(2));


figure
subplot(5,1,1)
plot(xStart:runTime, networkActivity(1,xStart:end)', 'linewidth', 2);
legend(neuronLabels(1), 'location', 'west')
set(gca, 'box', 'off', 'fontsize', 26)
xlim(xLims)

subplot(5,1,2:5)
thisPlotInds = {typeInds.pn, iLNs(typeInds.y), iLNs(typeInds.ts), iLNs(typeInds.d), typeInds.rem};
% networkActivity(2:end,:) = a(2:end, :);
plot(xStart:runTime, networkActivity(thisPlotInds{5},xStart:end)', 'linewidth', 2, 'color', [0.9, 0.9, 0.9])
hold on
plot(xStart:runTime, networkActivity(thisPlotInds{4},xStart:end)', 'linewidth', 2, 'color', [0.0, 0.75, 0.75])
plot(xStart:runTime, networkActivity(thisPlotInds{2},xStart:end)', 'linewidth', 2, 'color', [0.925, 0.69, 0.122])
plot(xStart:runTime, networkActivity(thisPlotInds{3},xStart:end)', 'linewidth', 2, 'color', [0.49, 0.18, 0.553])
plot(xStart:runTime, networkActivity(thisPlotInds{1},xStart:end)', 'linewidth', 4, 'color', [0.3, 0.5, 0.35])
thisPlotLabels = [neuronLabels(thisPlotInds{5}), neuronLabels(thisPlotInds{4}), neuronLabels(thisPlotInds{2}), neuronLabels(thisPlotInds{3}), neuronLabels(thisPlotInds{1})];
legend(thisPlotLabels, 'location', 'west', 'NumColumns', 3)
% legend(neuronLabels(2:end), 'location', 'west', 'NumColumns', 3)
set(gca, 'box', 'off', 'fontsize', 26, 'ylim', yLims)
xlim(xLims)
set(gcf, 'position', [0 0 1920 1200])
ylim(yLims);

% subplot(5,1,4:5)
% pnInput = networkActivity .* adjMat(:,iLNs(33));
% % networkActivity(2:end,:) = a(2:end, :);
% plot(xStart:runTime, pnInput(thisPlotInds{5},xStart:end)', 'linewidth', 2, 'color', [0.9, 0.9, 0.9])
% hold on
% plot(xStart:runTime, pnInput(thisPlotInds{4},xStart:end)', 'linewidth', 2, 'color', [0.0, 0.75, 0.75])
% plot(xStart:runTime, pnInput(thisPlotInds{2},xStart:end)', 'linewidth', 2, 'color', [0.925, 0.69, 0.122])
% plot(xStart:runTime, pnInput(thisPlotInds{3},xStart:end)', 'linewidth', 2, 'color', [0.49, 0.18, 0.553])
% plot(xStart:runTime, pnInput(thisPlotInds{1},xStart:end)', 'linewidth', 4, 'color', [0.3, 0.5, 0.35])
% thisPlotLabels = [neuronLabels(thisPlotInds{5}), neuronLabels(thisPlotInds{4}), neuronLabels(thisPlotInds{2}), neuronLabels(thisPlotInds{3}), neuronLabels(thisPlotInds{1})];
% % legend(thisPlotLabels, 'location', 'west', 'NumColumns', 3)
% % legend(neuronLabels(2:end), 'location', 'west', 'NumColumns', 3)
% set(gca, 'box', 'off', 'fontsize', 26, 'ylim', yLims)
% xlim(xLims)
% set(gcf, 'position', [0 0 1920 1200])
% ylim([min(min(pnInput(4:end, xStart:end))) max(max(pnInput(4:end, xStart:end)))]);
% 
