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
% stimulus = [zeros(100,1); ones(300,1); zeros(200,1)];
stimulus = [ones(1000,1)*0.2; ones(300,1); ones(200,1)*0.2];
taus = [0 15 15 100 100];
% taus = [0 10 15 150 150];
% adjMat(1,2) = 1;

timeStep = 1;
stepSize = 1;
runTime = 1500;

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
    networkActivity(2, timeStep) = networkActivity(2, timeStep) * nn(2).SynRes(timeStep);
%     networkActivity(3, timeStep) = networkActivity(2, timeStep) * nn(3).SynRes(timeStep);
%     networkActivity(4, timeStep) = networkActivity(2, timeStep) * nn(4).SynRes(timeStep);
%     networkActivity(5, timeStep) = networkActivity(2, timeStep) * nn(5).SynRes(timeStep);
end
a(1, :) = networkActivity(1,:);
figure
plot(a', 'linewidth', 2)
legend(neuronLabels, 'location', 'northwest')
set(gca, 'box', 'off', 'fontsize', 20)
% axis([0 1000 0 10])
% set(gcf, 'position', [0 0 1920 1200])
% set(gcf, 'position', [0 0 960 600])