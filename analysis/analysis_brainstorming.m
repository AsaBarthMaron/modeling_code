clear
mb = load('/n/scratch2/anb12/modeling_results/2019-04-13_synaptic_depression_param/2019-04-13_synaptic_dep_batch_workspace.mat');
param = mb.param;
paramD = mb.paramD;
nModels = mb.nModels;
saveDir = mb.saveDir;
fields = mb.fields;

% So this is going to be scratch for ModelAnalysis
% Handling data for analysis will not be super straightforward.
% This will be where I work out the strategy.

% First off, we need to convert param back to its original shape
param = reshape(param, paramD(1), paramD(2), paramD(3), paramD(4), paramD(5), paramD(6), paramD(7));

% Now just matching up each individual model with a PN response (in order
% to calculate an R^2) would be trivial. But We think it would be more
% interesting to concatenate many model runs into sets that span stimulus
% intensity and waveform. That way model performance is constrained in
% concentration and frequency tuning.


% Unfortunately only the PNs recorded on 2019-01-22 and 2019-01-31 had the
% strongest (10^-1) odor stimulus. But both of these cells had responses
% for 10^-4, 10^-2 as well. Only 1-16 and 1-22 had both highest and second
% highest odor concentrations (10^-1 and 10^-2) with 'square' stimulus, but
% for now I have decided to not look at the 'square' stimuli.

% Now let's load the PN responses we want.
pnData = load('/n/scratch2/anb12/modeling_results/2019-04-09_square_varstim_annotated_blocks.mat')
pn(1:2) = pnData.vs([3, 5]);
for iPN = 1:length(pn)
    pn(iPN).four = [];
    pn(iPN).two = [];
    pn(iPN).one = [];
end
for iCell = 1:length(pn)
    for iBlock = 1:length(pn(iCell).df)
        switch pn(iCell).df(iBlock).blockType
            case 'four'
                pn(iCell).four = cat(3, pn(iCell).four, squeeze(pn(iCell).psth(:,:,iBlock)));
            case 'two'
                pn(iCell).two = cat(3, pn(iCell).two, squeeze(pn(iCell).psth(:,:,iBlock)));
            case 'one'
                pn(iCell).one = cat(3, pn(iCell).one, squeeze(pn(iCell).psth(:,:,iBlock)));
        end
    end
end

pn(2).four = mean(pn(2).four,3);
pn(2).two = mean(pn(2).two,3);
pn(2).one = mean(pn(2).one,3);

% for i = 1:3
%     figure
%     plot(pn(1).two(:,i), 'linewidth', 2)
%     hold on
%     plot(pn(2).two(:,i), 'linewidth', 2)
% end
%
% figure
% j = 1;
% vFields = {'four', 'two', 'one'};
% for fn = vFields
%
%     for i = 1:3
%         for iPN = 1:2
%             iPlot = j + ((i-1) * 3);
%             subplot(3,3,iPlot)
%             p = pn(iPN).(fn{1});
%             plot((1/pnData.sampRate):(1/pnData.sampRate):(11), squeeze(p(:,i)) * 10e3, 'linewidth', 1.5)
%             hold on
%             yl = ylim;
%             yl(2) = 300;
%             ylim(yl);
%             %         plot((1/(pnData.sampRate)):(1/(pnData.sampRate)):(11), pn(1).os(:,i) * 280, 'k', 'linewidth', 10, 'color', [0.5 0.5 0.5])
%             %         area(os{i} / (100), ones(length(os{i}), 1) * yl(2),'FaceColor',[[0.45, 0.74, 0.88]],'FaceAlpha',.15,'EdgeAlpha',.15)
%             set(gca, 'box', 'off', 'fontsize', 20)
%         end
%     end
%
%     j = j+1;
% end
% for i = 1:3:9
%     subplot(3,3,i)
%     ylabel('Spikes / second')
% end
% for i = 7:9
%     subplot(3,3,i)
%     xlabel('Seconds')
% end
% subplot(3,3,1)
% title('2-hep 10^-^4')
% subplot(3,3,2)
% title('2-hep 10^-^2')
% subplot(3,3,3)
% title('2-hep 10^-^1')
%% Arrange PN data matrix
nPNs = 2;
for iPN = 1:nPNs
    pnMat(:,:,1, iPN) = downsample(pn(iPN).one, 10);
    pnMat(:,:,2, iPN) = downsample(pn(iPN).two, 10);
    pnMat(:,:,3, iPN) = downsample(pn(iPN).four, 10);
end
os = pn(1).os;
pnD = size(pnMat);
%% Load model sets & Perform analysis
% Each set has 3 waveforms and 4 stimuli.
% Each set will produce two triplet comparisons to PN data.
% This is done to prevent data being loaded in duplicate.
cd(saveDir)
% cd('/Users/asa/Modeling/modeling_results/2019-04-13_synaptic_depression_param')

rSq = NaN([paramD(3:end), 2, 2]); % 2 cells & 2 triplets
rWindow = (2e3+1):10e3;

tic
configCluster;
c = parcluster('o2 local R2018a');
c.AdditionalProperties.WallTime = '01:00:00';
c.AdditionalProperties.QueueName = 'short';
parpool(6)
parfor sORN = 1:paramD(3)
   parfor sPN = 1:paramD(4)
       for sLNtoORN = 1:paramD(5)
            for iDep = 1:paramD(6)
                for iTauRep = 1:paramD(7)
                    for iStim = 1:(paramD(1) - 1) % Not doing square for now
                        for iInt = 1:paramD(2)
                            p = param(iStim, iInt, sORN, sPN, sLNtoORN, iDep, iTauRep);
                            yesM = load([p.fname '.mat']);
                            modelSets(:, iStim, iInt) = yesM.m.NetworkActivity(53, :);
                        end
                    end
                    for iSet = 1:2
                        for iPN = 1:nPNs
                            % Select model set
                            ms = modelSets(rWindow+2e3, :, iSet:iSet+2);
                            % Select PN (2019-01-22, 2019-01-31)
                            ps = pnMat(rWindow, :, :, iPN);
                            % Calculate set correlation
                            r = corr(ms(:), ps(:));
                            % Assign R^2
                            rSq(sORN, sPN, sLNtoORN, iDep, iTauRep...
                                , iSet, iPN) = r^2;
                        end
                    end
                end
            end
        end
    end
end
toc




