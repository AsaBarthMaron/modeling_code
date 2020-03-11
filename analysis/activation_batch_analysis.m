clear
mb = load('/Users/asa/Modeling/modeling_results/2020-01-20_LN_silencing_batch_workspace/2020-01-20_LN_silencing_batch_workspace.mat');
param = mb.param;
paramD = mb.paramD;
nModels = mb.nModels;
fields = mb.fields;
% saveDir = mb.saveDir;   % Not being used b/c O2 saveDir is stored.
% saveDir = '/Users/asa/Modeling/modeling_results/2020-01-20_LN_silcencing_batch';

% Set structures & vars for handling models across LN manipulations.
lnManip = {'ctrl', 'y', 'ts', 'd'};
saveDir{1} = '/Users/asa/Modeling/modeling_results/2020-01-20_LN_silencing_batch';
saveDir{2} = ['/Users/asa/Modeling/modeling_results/2020-03-04_LN_activation_batch', '_y'];
saveDir{3} = [saveDir{2}(1:end-2), '_ts'];
saveDir{4} = [saveDir{2}(1:end-2), '_d'];

%% Iterate through model parameters, load  models for all manipulations
nParam = length(param);
nManip = length(lnManip);

p = reshape(param, paramD(1), paramD(2), paramD(3), paramD(4), paramD(5), paramD(6), paramD(7));
% p = squeeze(p(1, 3,3, 3,3, 3, 2));

% Initailize data matrices for metrics
pk = NaN(nParam, nManip);
ss = NaN(nParam, nManip);
mn = NaN(nParam, nManip);
int = NaN(nParam, nManip);

pnFR = NaN(nParam, nManip, 3e3);

pkRange = 1e3+1:1.2e3;
ssRange = 1.8e3+1:2e3;
minRange = 2e3+1:2.2e3;
intRange = 1e3+1:2e3;


tic
date = {'2020-01-20', '2020-03-04', '2020-03-04', '2020-03-04'};
for iParam = 1:nParam
    for iManip = 1:nManip
        % Load model, get FR
        
        tmpModel = load(fullfile(saveDir{iManip} , [date{iManip} param(iParam).fname(11:end) '.mat']));
        m(iManip) = tmpModel.m;
        pnFR(iParam, iManip, :) = m(iManip).NetworkActivity(53,1e3+1:end);
        
        % Calculate metrics
        pk(iParam, iManip) = max(pnFR(iParam, iManip, pkRange));
        ss(iParam, iManip) = mean(pnFR(iParam, iManip, ssRange), 3);
        mn(iParam, iManip) = min(pnFR(iParam, iManip, minRange));
        int(iParam, iManip) = sum(pnFR(iParam, iManip, pkRange));
    end
end
toc
% save('/Users/asa/Modeling/modeling_results/2020-01-20_LN_silencing_batch_workspace/2020-01-20_LN_silencing_batch_analysis.mat');

% Plot histogram of each metric
figure
subplot(2,2,1)
histogram(pk(:))

subplot(2,2,2)
histogram(ss(:))

subplot(2,2,3)
histogram(mn(:))

subplot(2,2,4)
histogram(int(:))


%% 
df_pk = pk(:, 1) - pk(:, 2:end);
df_ss = ss(:, 1) - ss(:, 2:end);
df_mn =  mn(:, 1) - mn(:, 2:end);
df_int = int(:, 1) - int(:, 2:end);

plotInds = [1:100, nParam-100+1:nParam];

figure
subplot(2,2,1)
tmp = sort(df_pk, 'descend');
plot(tmp(plotInds, :), '*')
legend(lnManip(2:end))
title ('Peak FR diff')
xlabel('Top & bottom 100 models')
ylabel('Diff: Ctrl - LN pert.')
set(gca, 'fontsize', 20, 'box', 'off', 'tickdir', 'out')

subplot(2,2,2)
tmp = sort(df_ss, 'descend');
plot(tmp(plotInds, :), '*')
legend(lnManip(2:end))
title ('Steady-state FR diff')
xlabel('Top & bottom 100 models')
ylabel('Diff: Ctrl - LN pert.')
set(gca, 'fontsize', 20, 'box', 'off', 'tickdir', 'out')

subplot(2,2,3)
tmp = sort(df_mn, 'descend');
plot(tmp(plotInds, :), '*')
legend(lnManip(2:end))
title ('Min post-stimulus diff')
xlabel('Top & bottom 100 models')
ylabel('Diff: Ctrl - LN pert.')
set(gca, 'fontsize', 20, 'box', 'off', 'tickdir', 'out')

subplot(2,2,4)
tmp = sort(df_int, 'descend');
plot(tmp(plotInds, :), '*')
legend(lnManip(2:end))
title ('Integrated diff')
xlabel('Top & bottom 100 models')
ylabel('Diff: Ctrl - LN pert.')
set(gca, 'fontsize', 20, 'box', 'off', 'tickdir', 'out')
%% Quick batch analysis - no con type param combinations

% for iModel = 1:nModels
%     disp('Loading data...')
%     tmpModel = load(fullfile(saveDir, param(iModel).fname));
%     m(iModel) = tmpModel.m;
% end
% disp('Data loaded')









































%% Quick batch analysis - no con type param combinations
% 
% param = reshape(param, paramD(1), paramD(2), paramD(3), paramD(4), paramD(5), paramD(6), paramD(7));
% 
% p(:,:,1) = squeeze(param(1,:,:,2,2,2,2));
% p(:,:,2) = squeeze(param(1,:,2,:,2,2,2));
% p(:,:,3) = squeeze(param(1,:,2,2,:,2,2));
% p(:,:,4) = squeeze(param(1,:,2,2,2,:,2));
% p(:,:,5) = squeeze(param(1,:,2,2,2,2,:));
% 
% pD = size(p);
% nIntensities = pD(1);
% p = p(:);
% 
% disp('Loading data...')
% for iModel = 1:length(p)
%     tmpModel = load([fullfile(saveDir, p(iModel).fname) '.mat']);
%     m(iModel) = tmpModel.m;
% end
% disp('Data loaded')
% 
% p = reshape(p, pD(1), pD(2), pD(3));
% m = reshape(m, pD(1), pD(2), pD(3));
% % m = permute(m, [2 1 3]);    %
% 
% close all
% 
% for iConType = 1:pD(3)
%     fn = fields(iConType + 3);
%     figure
%     subplot(4,nIntensities,1)
%     for iScalarVal = 1:pD(2)
%         for iIntensity = 1:nIntensities
%             iPlot = sub2ind([nIntensities, 4], iIntensity, iScalarVal);
%             subplot(4,nIntensities, iPlot)
%             pnFR = m(iIntensity, iScalarVal, iConType).NetworkActivity(53,:);
%             iORNSynRes = m(iIntensity, iScalarVal, iConType).nn(2).SynRes;
%             iORNRel = m(iIntensity, iScalarVal, iConType).nn(2).Rel;
% 
%             plot(pnFR(1e3:(3.5e3-1)), 'linewidth', 1.5)
% %             plot(iORNSynRes(1e3:(3.5e3-1)), 'linewidth', 1.5)
%             hold on
% %             plot(iORNRel(1e3:(3.5e3-1))/8, 'linewidth', 1.5)
% %             ylim([0 1])
% 
%             set(gca, 'box', 'off', 'fontsize', 18)
%         end
%     end
%     yPlots = 1:nIntensities:(4*nIntensities);
%     for iYPlot = 1:4
%         subplot(4,nIntensities, yPlots(iYPlot))
%         ylabel([fn{1}, ' - ', num2str(p(1, iYPlot, iConType).(fn{1}))]);
%     end
%     for iXPlot = 1:nIntensities
%         subplot(4,nIntensities, iXPlot)
%         title(['Stimulus intensity - ', num2str(p(iXPlot, 1, iConType).intensity), 'x']);
%     end
%     legend({'PN firing rate'})
% %     legend({'iORN Synaptic resources', 'iORN release'})
% end

