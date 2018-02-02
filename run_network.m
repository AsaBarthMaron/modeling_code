% adjacency matrix
% set inputs based on entries in matrix
% set network StepSize and RunTime


% adjMat = [0.0, 1.0, 0.0, 0.0, 0.0;... 
%           0.0, 0.0, 1.0, 0.1, 1.0;...
%           0.0, 0.0, 0.0, 1.0, 0.1;...
%           0.0, -0.1, -0.3, -0.3, -0.3;...
%           0.0, -0.8, -0.1, -0.3, -0.0]; 2
% load('/home/asa/Modeling/adjMat.mat');
load('Z:\Modeling\adjMat.mat');
neuronLabels = {'stimulus', 'ORN', 'PN', 'LN_1', 'LN_2'};

sampRate = 1000;
impulse{1} = [ones((0.02 * sampRate),1)*1; ones((0.08 * sampRate),1)*0.2];
impulse{2} = [ones((0.2 * sampRate),1)*1; ones((0.38 * sampRate),1)*0.2];
impulse{3} = [ones((2 * sampRate),1)*1; ones((1.58 * sampRate),1)*0.2];
    
% stimulus = [ones(2000,1)*0.2; repmat(impulse{1}, 60, 1); ones(1000,1)*0.2];
% stimulus = [ones(2000,1)*0.2; repmat(impulse{2}, 10, 1); ones(1000,1)*0.2];
% stimulus = [ones(2000,1)*0.2; repmat(impulse{3}, 2, 1); ones(1000,1)*0.2];

stimulus = [ones(2000,1)*0.2; ones(300,1); ones(1000,1)*0.2];
% stimulus = [ones(2000,1)*0.2; [sin([1:1:300]/10) + 1]'; ones(1000,1)*0.2];
taus = [0 15 15 100 100];
% taus = [0 10 15 150 150];
% adjMat(1,2) = 1;

timeStep = 1;
stepSize = 1;
runTime = length(stimulus);

for i = 1:length(neuronLabels)
    nn(i) = Neuron();
end

for i = 1:length(nn)
    nn(i).Name = neuronLabels{i};
    nn(i).TimeStep = timeStep;
    nn(i).StepSize = stepSize;
    nn(i).RunTime = runTime;
    nn(i).NSteps = nn(i).RunTime ./ nn(i).StepSize;
    nn(i).Tau = taus(i);
    nn(i).TauKrn = exp((1:300)/nn(i).Tau);
    nn(i).TauKrn = nn(i).TauKrn ./ sum(nn(i).TauKrn);
    nn(i).Inputs = adjMat(:,i);
    nn(i).Vm = zeros(nn(i).NSteps, 1);
    nn(i).FR = zeros(nn(i).NSteps, 1);
    nn(i).Rel = zeros(nn(i).NSteps, 1);
    nn(i).SynRes = ones(nn(i).NSteps, 1);
    nn(i).IntegratedFR = zeros(nn(i).NSteps, 1);
end

networkActivity = zeros(length(nn), runTime);
networkActivity(1, :) = stimulus;
for timeStep = 301:runTime
    for i = 2:length(nn)
        nn(i).sumInputs(networkActivity, timeStep);
        nn(i).tauIntegrate(networkActivity, timeStep);

        nn(i).rectify(timeStep);
        nn(i).Rel(timeStep) = nn(i).FR(timeStep);
        nn(i).calcResources(timeStep);
%         nn(i).saturate(timeStep);
        networkActivity(i, timeStep) = nn(i).FR(timeStep);
        a(i, timeStep) = nn(i).FR(timeStep);
    end
%     networkActivity(2:5, timeStep) = networkActivity(2:5,timeStep) + (rand(4,1)/1000);
    networkActivity(2, timeStep) = networkActivity(2, timeStep) * nn(2).SynRes(timeStep);
%     networkActivity(3, timeStep) = networkActivity(2, timeStep) * nn(3).SynRes(timeStep);
%     networkActivity(4, timeStep) = networkActivity(2, timeStep) * nn(4).SynRes(timeStep);
%     networkActivity(5, timeStep) = networkActivity(2, timeStep) * nn(5).SynRes(timeStep);
end
%%
yLims(2) = max(max(networkActivity(2:end, 1000:end)));
yLims(2) = yLims(2) * 1.5;
yLims(1) = 0;
a(1, :) = networkActivity(1,:);
networkActivity(1,:) = ((networkActivity(1,:) / max(networkActivity(1,:))) * yLims(2)/10) + (0.8 * yLims(2));
figure
plot(1000:runTime, networkActivity(:,1000:end)', 'linewidth', 2)
ylim = yLims;
legend(neuronLabels, 'location', 'west')
set(gca, 'box', 'off', 'fontsize', 20, 'ylim', yLims)
% axis([0 1000 0 10])
set(gcf, 'position', [0 0 1920 1200])
% set(gcf, 'position', [0 0 960 600])