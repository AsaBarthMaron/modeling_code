clear
mb = load('/Users/asa/Modeling/modeling_results/2019-03-28_parameter_comb_sim_syn_dep_PN_ORN_to_ORN_silenced/2019-03-28_ORN_PN_to_ORN_0_model_batch_workspace.mat');
param = mb.param;
paramD = mb.paramD;
nModels = mb.nModels;
saveDir = mb.saveDir;
fields = mb.fields;
% 
% for iModel = 1:nModels
%     disp('Loading data...')
%     tmpModel = load(fullfile(saveDir, param(iModel).fname));
%     m(iModel) = tmpModel.m;
% end
% disp('Data loaded')

%% Quick batch analysis - no con type param combinations

param = reshape(param, paramD(1), paramD(2), paramD(3), paramD(4), paramD(5), paramD(6), paramD(7));

p(:,:,1) = squeeze(param(1,:,:,2,2,2,2));
p(:,:,2) = squeeze(param(1,:,2,:,2,2,2));
p(:,:,3) = squeeze(param(1,:,2,2,:,2,2));
p(:,:,4) = squeeze(param(1,:,2,2,2,:,2));
p(:,:,5) = squeeze(param(1,:,2,2,2,2,:));

pD = size(p);
p = p(:);

disp('Loading data...')
for iModel = 1:length(p)
    tmpModel = load(fullfile(saveDir, p(iModel).fname));
    m(iModel) = tmpModel.m;
end
disp('Data loaded')

p = reshape(p, pD(1), pD(2), pD(3));
m = reshape(m, pD(1), pD(2), pD(3));
% m = permute(m, [2 1 3]);    %

close all

for iConType = 1:pD(3)
    fn = fields(iConType + 2);
    figure
    subplot(4,4,1)
    for iScalarVal = 1:pD(2)
        for iIntensity = 1:pD(1)
            iPlot = sub2ind([4, 4], iIntensity, iScalarVal);
            subplot(4,4, iPlot)
            pnFR = m(iIntensity, iScalarVal, iConType).NetworkActivity(53,:);
            iORNSynRes = m(iIntensity, iScalarVal, iConType).nn(2).SynRes;
            iORNRel = m(iIntensity, iScalarVal, iConType).nn(2).Rel;

            plot(pnFR(1e3:(3.5e3-1)), 'linewidth', 1.5)
            plot(iORNSynRes(1e3:(3.5e3-1)), 'linewidth', 1.5)
            hold on
            plot(iORNRel(1e3:(3.5e3-1))/8, 'linewidth', 1.5)
            ylim([0 1])

            set(gca, 'box', 'off', 'fontsize', 18)
        end
    end
    yPlots = 1:4:16;
    for iYPlot = 1:4
        subplot(4,4, yPlots(iYPlot))
        ylabel([fn{1}, ' - ', num2str(p(1, iYPlot, iConType).(fn{1}))]);
    end
    for iXPlot = 1:4
        subplot(4,4, iXPlot)
        title(['Stimulus intensity - ', num2str(p(iXPlot, 1, iConType).intensity), 'x']);
    end
%     legend({'PN firing rate'})
    legend({'iORN Synaptic resources', 'iORN release'})
end

