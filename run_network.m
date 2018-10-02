function networkActivity = run_network(adjMat)
% RUN_NETWORK creates a network and runs it for a single trial condition

% Input parameters -
%     adjMat:         Adjacency matrix of connections (first row = stim output)
%     inhbCon:        Ordered pairs identifying which connections are 
%                     inhibitory
%     preCon:         Ordered pairs of connections that are inhibitory and
%                     target presynaptic terminals
%     depCon:         Ordered pairs of connections that have synaptic
%                     depletion
%     taus:           Vector of time constants for each neuron
%% Synthesize stimulus waveform

% staircase
StepSize = 1;                % ms
stimIncrement = 1.5;
baseline = zeros(2000, 1);
StimulusOnset = length(baseline);
stimulus = baseline;
for i=1:8
    stimulusLevels(i) = stimIncrement*2^i;
end
stimSnippetLength = 500;
for i = 1:8
    stimSegment = zeros(stimSnippetLength, 1)+stimulusLevels(i);
    stimulus = [stimulus;stimSegment];
end
% flippedStimulus = flip(stimulus);
% stimulus = [stimulus;flippedStimulus];
runTime = length(stimulus)*StepSize; % ms
NSteps = runTime ./ StepSize;

% small linear steps up from 1
% StepSize = 1;                % ms
% stimIncrement = .4;
% baselineLevel = 3;
% baseline = ones(2000, 1)*baselineLevel;
% StimulusOnset = length(baseline);
% stimSnippetLength = 500;
% stimSegment = (ones(stimSnippetLength, 1)*baselineLevel)+stimIncrement;
% spacer = ones(stimSnippetLength, 1)*baselineLevel;
% stimulus = [baseline;stimSegment;spacer;stimSegment;spacer;stimSegment;spacer;stimSegment;spacer;stimSegment;spacer;stimSegment;spacer;stimSegment;spacer];
% runTime = length(stimulus)*StepSize; % ms
% NSteps = runTime ./ StepSize;

%% Name objects
objectLabels = {'stimulus' 'leftORNl' 'rightORNl' 'leftLN' 'leftPN' 'rightORNr' 'leftORNr' 'rightLN' 'rightPN'};
nNeurons = length(objectLabels);  % Number of objects in network

%% Augment adjacency matrix
thisRunAdjMat = adjMat; % copies adjacency matrix into a temporary copy for this run
if ((size(thisRunAdjMat,1) ~= 4) || (size(thisRunAdjMat,2) ~= 4))
    disp('thisRunAdjMat size error 1')
else
    newObj = zeros(4,1);
    thisRunAdjMat = horzcat(newObj,thisRunAdjMat,newObj,newObj,newObj,newObj);
    newObj = zeros(1,9);
    thisRunAdjMat = vertcat(newObj,thisRunAdjMat,newObj,newObj,newObj,newObj);
    if ((size(thisRunAdjMat,1) ~= 9) || (size(thisRunAdjMat,2) ~= 9))
        disp('thisRunAdjMat size error 2')
    else
    thisRunAdjMat(1,2) = 1; % stimulus input to leftORNl
    thisRunAdjMat(1,3) = .5; % stimulus input to rightORNl
    thisRunAdjMat(1,6) = .5; % stimulus input to rightORNr
    thisRunAdjMat(1,7) = 1; % stimulus input to leftORNr
    thisRunAdjMat(6:9,6:9) = thisRunAdjMat(2:5,2:5); % mirror right and left synaptic connections
    end
end

%% Define cells used in this particular run
runCellList = [2:9]; % start with 2 and always include ORNs (but not the stimulus, which is 1)

%% Initialize and set timing variables
sampRate = 1000; % 1000 samples/s. Should not change. 
stepSize = (1 / sampRate) * 1e3; % Size (in ms) of each time step

timeStep = 1;   % Sample at which to initialize model
runTime = length(stimulus); % Model run time (in samples)
%% Set free parameters
LNtoPNScalar = .05; % values <1 weaken the effect of postsynaptic inhibition onto PNs
LNtoLNScalar = .05; % values <1 weaken the effect of postsynaptic inhibition onto LNs
PNtoLNScalar = .05; % values <1 weaken the effect of PN->LN connections
DepletionRate = 0.0073; % per "release unit" (intermediate between fast and slow values from Nagel et al. 2015, i.e. 0.23 and 0.0073)
TauReplenishment = 1000; %  ms (from Nagel et al. 2015)
preInhibitionScalar = .01; % hand-tuned to adjust strength of presynaptic inhibition
ReleaseImpactScalar = 0.01; % hand-tuned; this factor scales the impact of ORN release on target cells to scale overall input to network
taus = zeros(1,9); % time constants for each object
taus(1,2:3) = 15; % ORN
taus(1,6:7) = 15; % ORN
taus(1,5) = 15; % PN
taus(1,9) = 15; % PN
taus(1,4) = 15; % LN
taus(1,8) = 15; % LN
biases = zeros(1,9); % neuron-specific biases (effects of leak conductances or spike thresholds)

if ((nNeurons ~= length(taus)) || (nNeurons ~= length(biases)))
    disp('nNeurons length error')
    pause
end
%% Manipulate adjacency matrix to make it useable for a simulation
thisRunAdjMat(4,:) = - thisRunAdjMat(4,:); % make LN outputs negative
thisRunAdjMat(8,:) = - thisRunAdjMat(8,:); % make LN outputs negative

thisRunAdjMat(4,5) = thisRunAdjMat(4,5) * LNtoPNScalar;
thisRunAdjMat(8,9) = thisRunAdjMat(8,9) * LNtoPNScalar;

thisRunAdjMat(4,4) = thisRunAdjMat(4,4) * LNtoLNScalar;
thisRunAdjMat(8,8) = thisRunAdjMat(8,8) * LNtoLNScalar;

thisRunAdjMat(5,4) = thisRunAdjMat(5,4) * PNtoLNScalar;
thisRunAdjMat(9,8) = thisRunAdjMat(9,8) * PNtoLNScalar;
 
%% Zero ORN and PN connections (which are not relevant to these simulations)
thisRunAdjMat(2:3,2:3) = 0; % zero ORN-ORN connections
thisRunAdjMat(6:7,6:7) = 0; % zero ORN-ORN connections

thisRunAdjMat(5,5) = 0; % zero PN-PN connections
thisRunAdjMat(9,9) = 0; % zero PN-PN connections

thisRunAdjMat(5,2:3) = 0; % zero PN-ORN connections
thisRunAdjMat(9,6:7) = 0; % zero PN-ORN connections

%% Experiments on the model
% thisRunAdjMat(4,:) = 0; % zero LN outputs
% thisRunAdjMat(8,:) = 0; % zero LN outputs
% thisRunAdjMat(5,4) = 0; % zero PN-LN connections
% thisRunAdjMat(9,8) = 0; % zero PN-LN connections
% thisRunAdjMat(4,5) = 0; % zero LN-PN connections
% thisRunAdjMat(8,9) = 0; % zero LN-PN connections
% thisRunAdjMat(4,2:3) = 0; % zero LN-ORN connections
% thisRunAdjMat(8,6:7) = 0; % zero LN-ORN connections
% dummyleft = thisRunAdjMat(2,4);
% dummyright = thisRunAdjMat(6,8);
% thisRunAdjMat(2,4) = thisRunAdjMat(3,4); % make ipsiORN>LN connection equal to contraORN>LN connection
% thisRunAdjMat(6,8) = thisRunAdjMat(7,8); % make ipsiORN>LN connection equal to contraORN>LN connection
% thisRunAdjMat(3,4) = dummyleft;
% thisRunAdjMat(7,8) = dummyright;
% thisRunAdjMat(4,3) = thisRunAdjMat(4,2); % make left LN inhibit contraORN as much as ipsiORN
% thisRunAdjMat(8,7) = thisRunAdjMat(8,6); % make right LN inhibit contraORN as much as ipsiORN
% thisRunAdjMat(2,4) = thisRunAdjMat(3,4); % make ipsiORN>LN as strong as contraORN>LN
% thisRunAdjMat(6,8) = thisRunAdjMat(7,8); % make ipsiORN>LN as strong as contraORN>LN
% thisRunAdjMat(3,4) = 0; % zero contraORN>LN connection
% thisRunAdjMat(7,8) = 0; % zero contraORN>LN connection
% thisRunAdjMat(4,3) = 0; % zero LN>contraORN connection
% thisRunAdjMat(8,7) = 0; % zero LN>contraORN connection
% thisRunAdjMat(3,5) = 0; % zero contraORN>PN connection
% thisRunAdjMat(7,9) = 0; % zero contraORN>PN connection

%% Omits objects not used in this particular run
for iN=2:nNeurons % for all cells (omitting stimulus index)
    if (ismember(iN,runCellList) == 0) % if cell should not be included in run
        thisRunAdjMat(iN,:)=0; % zero that cell's inputs
        thisRunAdjMat(:,iN)=0; % zero that cell's outputs
    end
end

%% Create matrices to mark depleting connections and presynaptic inhibition
depCon = zeros((nNeurons-1)*4,2);
for i=1:(nNeurons-1)
    depCon(i,:) = [2 i+1];
    depCon(nNeurons-1+i,:) = [3 i+1];
    depCon(2*(nNeurons-1)+i,:) = [6 i+1];
    depCon(3*(nNeurons-1)+i,:) = [7 i+1];
end
preCon = [4,2;4,3;8,6;8,7]; % connections that are inhibitory and target presynaptic terminals
isDep = false(nNeurons, nNeurons); % make logical matrix of zeroes
isPre = false(nNeurons, nNeurons); % make logical matrix of zeroes
isDep(sub2ind(size(isDep), depCon(:,1), depCon(:,2))) = 1; % assign 1 to depleting connections
isPre(sub2ind(size(isPre), preCon(:,1), preCon(:,2))) = 1; % assign 1 to presynaptic inhibition connections

%% Housekeeping prior to running the simulation

% Instantiate each object
for iN = 1:nNeurons  % iN is the index for enumerating objects
    nn(iN) = Neuron(runTime, StepSize, NSteps, DepletionRate, TauReplenishment, preInhibitionScalar);
end

% Create matrix for holding network activity values
inputActivity = ones(length(nn), runTime);
inputActivity(1, :) = stimulus; % the first object in the network  is the stimulus
networkFR = inputActivity;
networkReleaseImpact = inputActivity;
networkActivity = inputActivity;

% Define simulation kernel length
kernLen = 300;  % Length of kernel (ms)
   
% Define properties of each object
 for iN = [1,runCellList] % be sure to include iN=1 here (i.e., the stimulus)
    nn(iN).Name = objectLabels{iN}; % Get object name
    nn(iN).TimeStep = timeStep; % Copy shared properties to object
    nn(iN).StepSize = stepSize; 
    nn(iN).runTime = runTime;
    nn(iN).NSteps = nn(iN).runTime ./ nn(iN).StepSize;
    nn(iN).Tau = taus(iN); % Get the object-specific time constant
    nn(iN).TauKrn = exp(-(1:kernLen)/nn(iN).Tau); % Calculate the object-specific kernel
    nn(iN).TauKrn = fliplr(nn(iN).TauKrn);
    nn(iN).TauKrn = nn(iN).TauKrn ./ sum(nn(iN).TauKrn);
    nn(iN).Inputs = thisRunAdjMat(:,iN); % assign each input column in adjMat to a postsynaptic cell
    nn(iN).SummedInput =    ones(nn(iN).NSteps, 1); % define variables over time
    nn(iN).FR =             ones(nn(iN).NSteps, 1);
    nn(iN).Rel =            ones(nn(iN).NSteps, 1);
 end
 
%% Generate ORN noise
% rng(1000); % set random seed
% leftORNnoise = .2 * wgn(1,runTime,0);
% rng(2000); % set random seed
% rightORNnoise = .2 * wgn(1,runTime,0);

 %% Values are calculated one step at a time using the forward Euler method.
for timeStep = (kernLen + 1):runTime
    for iN = runCellList
        iDep = isDep(:,iN);
        % pass activity forward for depleting connections
        inputActivity(iDep, timeStep-1) = networkReleaseImpact(iDep, timeStep-1);
        % pass activity forward for nondepleting connections
        inputActivity(~iDep, timeStep-1) = networkFR(~iDep, timeStep-1);
        
        % calculate summed inputs (a.u.)
        notPre = ~isPre(:, iN); % use only connections that are not presynaptic inhibition
        nn(iN).calcSummedInput(inputActivity, timeStep, notPre);
        
        % add neuron-specific bias
        nn(iN).SummedInput = nn(iN).SummedInput + biases(iN);
        
        % calculate firing rate (a.u.)
        if ((iN==2) || (iN==3) || (iN==6) || (iN==7)) % for ORNs
            nn(iN).calcLinearFR(timeStep);
        else % for LNs and PNs
            nn(iN).calcRectifiedFR(timeStep);
        end
        
        % calculate Rel ("release units"/s)
        if ((iN==2) || (iN==3) || (iN==6) || (iN==7)) % for ORNs
            nn(iN).calcRel(inputActivity, timeStep, isPre(:, iN), StimulusOnset);
        end
        
%         % add ORN noise
%         if ((iN==2) || (iN==7)) % for leftORN
%             nn(iN).Rel(timeStep) = nn(iN).Rel(timeStep)+leftORNnoise(timeStep);
%         end
%         if ((iN==3) || (iN==6)) % for leftORN
%             nn(iN).Rel(timeStep) = nn(iN).Rel(timeStep)+rightORNnoise(timeStep);
%         end
        
        % assign calculated values to network outputs
        networkFR(iN, timeStep) = nn(iN).FR(timeStep);
        networkReleaseImpact(iN, timeStep) = nn(iN).Rel(timeStep) * ReleaseImpactScalar;
    end
end

networkActivity = inputActivity;
networkOutput = networkActivity(:,1000:runTime-2);

% add PN noise
% rng(1); % set random seed
% PNresponse = networkOutput(5,:);
% cn = dsp.ColoredNoise('Color','white','SamplesPerFrame',length(PNresponse));
% noise = (cn() * 0.05 * (max(PNresponse) - min(PNresponse)))';
% networkOutput(5,:) = PNresponse + noise;
% rng(2); % set random seed
% PNresponse = networkOutput(7,:);
% cn = dsp.ColoredNoise('Color','white','SamplesPerFrame',length(PNresponse));
% noise = (cn() * 0.05 * (max(PNresponse) - min(PNresponse)))';
% networkOutput(7,:) = PNresponse + noise;
%% Plot network output
plotList = [5,9];
plotList(plotList == 2) = []; % remove ORN
plotList(plotList == 3) = []; % remove ORN
plotList(plotList == 6) = []; % remove ORN
plotList(plotList == 7) = []; % remove ORN
figure('Name','strong ipsiORN>LN, no contraORN>LN');
subplot(2,1,1);
plot(networkOutput(1,:)','linewidth',1,'color','black');
axis tight;
ylim([0 max(networkOutput(1,:))]);
subplot(2,1,2);
hold on;
for iN = (plotList) % neurons to plot
    if ((iN == 5) || (iN == 9))
        if (iN == 5)
            plot(networkOutput(iN,:)','linewidth',1,'color','black');
        else
            plot(networkOutput(iN,:)','linewidth',1,'color',[.8 .8 .8]);
        end
    else
        plot(networkOutput(iN,:)','linewidth',1);
    end
        
end
axis tight;
% ylim([0 28]);
%legend(objectLabels(plotList), 'location', 'northwest'); % labels to plot
%% Analyze variance
% figure
% centeredStimulus = networkActivity(1,StimulusOnset:runTime-2) - mean(networkActivity(1,StimulusOnset:runTime-2));
% h1 = histogram(centeredStimulus);
% h1.BinWidth = 0.2;
% hold on
% centeredPN = networkActivity(3,StimulusOnset:runTime-2) - mean(networkActivity(3,StimulusOnset:runTime-2));
% h2 = histogram(centeredPN);
% h2.BinWidth = 0.2;
% legend(objectLabels([1, 3]), 'location', 'northwest');
%% Analyze steady-state responses
% figure
% stimulusLevels = [0 stimulusLevels]; % add baseline point
% for i=1:9
%     SteadyStatePNresp(i) = mean(networkOutput(19,(400+(i*500)):(499+(i*500))));
% end
% SteadyStatePNresp = SteadyStatePNresp / max(SteadyStatePNresp);
% plot(stimulusLevels,SteadyStatePNresp, 'linewidth',2,'color', 'black');
% set(gca,'XLim',[0 max(stimulusLevels)],'XTick',[0 100 200 300]);
% set(gca,'YLim',[0 1],'YTick',[0 1]);
%% Compare left and right PNs
% figure
% if stimulusLevels(1,1) ~= 0
%     stimulusLevels = [0 stimulusLevels]; % add baseline point
% end
% leftPN = networkOutput(5,:);
% rightPN = networkOutput(7,:);
% PNs = vertcat(rightPN,leftPN);
% LeftMinusRightPN = diff(PNs);
% LeftMinusRightPN(LeftMinusRightPN<0) = 0; % set values to zero where right PN is higher
% LeftMinusRightPN(LeftMinusRightPN>0) = 1; % set values to one where left PN is higher
% for i=1:9
%     beginsnippet = 400+(i*stimSnippetLength);
%     endsnippet = 499+(i*stimSnippetLength);
%     snippet = LeftMinusRightPN(beginsnippet:endsnippet);
%     LeftHigherScore(i) = sum(snippet)/length(snippet);
% end
% plot(stimulusLevels,LeftHigherScore, 'linewidth',2,'color', 'black');
% set(gca,'XLim',[0 max(stimulusLevels)],'XTick',[0 100 200 300]);
% set(gca,'YLim',[0.49 1],'YTick',[0.5 1]);