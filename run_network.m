% adjacency matrix
% set inputs based on entries in matrix
% set network StepSize and RunTime


% adjMat = [0.0, 1.0, 0.0, 0.0, 0.0;... 
%           0.0, 0.0, 1.0, 0.1, 1.0;...
%           0.0, 0.0, 0.0, 1.0, 0.1;...
%           0.0, -0.1, -0.3, -0.3, -0.3;...
%           0.0, -0.8, -0.1, -0.3, -0.0]; 
load('/home/asa/Modeling/adjMat.mat');
% load('Z:\Modeling\adjMat.mat');
neuronLabels = {'stimulus', 'ORN', 'PN', 'LN_1', 'LN_2'};
stimulus = [zeros(100,1); ones(300,1); zeros(200,1)];
% stimulus = [ones(100,1)*0.1; ones(300,1); ones(200,1)*0.1];

timeStep = 1;
stepSize = 5;
runTime = 600;

for i = 1:length(neuronLabels)
    nn(i) = Neuron();
end

for i = 1:length(nn)
    nn(i).Name = neuronLabels{i};
    nn(i).TimeStep = timeStep;
    nn(i).StepSize = stepSize;
    nn(i).RunTime = runTime;
    nn(i).Inputs = adjMat(:,i);
    nn(i).Response(timeStep) = 0;
end

% d = exp(1:20)/max(exp(1:20));
% d = 0.1:0.1:1;
% d = ones(1,5);
networkActivity = zeros(length(nn), runTime);
networkActivity(1, :) = stimulus;
for timeStep = 21:runTime
    for i = 2:length(nn)
%         nn(i).sumInputs(networkActivity(:, timeStep -1), timeStep);
        nn(i).sumInputs(sum(networkActivity(:, timeStep-5:timeStep -1),2), timeStep);
%         history = networkActivity(:, timeStep-20:timeStep -1) * d';
%         nn(i).sumInputs(history, timeStep);
        nn(i).rectify(timeStep);
        networkActivity(i, timeStep) = nn(i).Response(timeStep);
    end
end
figure
plot(networkActivity', 'linewidth', 2)
legend(neuronLabels)
set(gca, 'box', 'off', 'fontsize', 20)