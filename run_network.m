function networkActivity = run_network(adjMat, preCon, depCon)
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

% % staircase
StepSize = 1;                % ms
stimIncrement = 1.5;
baseline = zeros(2000, 1);
StimulusOnset = length(baseline);
stimulus = baseline;
for i=1:8
    stimulusLevels(i) = stimIncrement*2^i;
end
for i = 1:8
    stimSegment = zeros(500, 1)+stimulusLevels(i);
    stimulus = [stimulus;stimSegment];
end
% flippedStimulus = flip(stimulus);
% stimulus = [stimulus;flippedStimulus];
runTime = length(stimulus)*StepSize; % ms
NSteps = runTime ./ StepSize;

% steps with fixed additive noise
% StepSize = 1;                % ms
% baseline = ones(1500, 1);
% StimulusOnset = length(baseline);
% stimulus1 = ones(3000, 1);
% snr = 0.01;
% stimulus1 = awgn(stimulus1,snr);
% stimulus = [baseline;stimulus1];
% for (stimulusIndex=1:5)
%     stimulus1 = ones(3000, 1);
%     stimulus1(:,1) = stimulus1(:,1)+(stimulusIndex*2);
%     snr = 0.01;
%     stimulus1 = awgn(stimulus1,snr);
%     stimulus = [stimulus;stimulus1];
%     stimulusIndex = stimulusIndex+1;
% end
% runTime = length(stimulus)*StepSize; % ms
% StepSize = 1;               % ms
% NSteps = runTime ./ StepSize;
% stimulus = stimulus+2.5;

% increasing magnitudes of pink noise
% StepSize = 1;                % ms
% stimulusEpochLength = 3000;
% stimulusIndexMax = 6;
% stimulus = zeros(stimulusEpochLength*stimulusIndexMax,1);
% rng(3); % set random seed
% cn = dsp.ColoredNoise('Color','pink','SamplesPerFrame',length(stimulus));
% noise = cn();
% stimulus = stimulus + (0.2*noise);
% for (stimulusIndex=1:stimulusIndexMax)
%     snipbegin = ((stimulusIndex-1)*stimulusEpochLength)+1;
%     snipend = stimulusIndex*stimulusEpochLength;
%     stimulus(snipbegin:snipend,1) = stimulus(snipbegin:snipend,1) .* stimulusIndex;
%     stimulusIndex = stimulusIndex+1;
% end
% baseline = zeros(2000, 1);
% stimulus = [baseline;stimulus];
% StimulusOnset = length(baseline);
% stimulusMin = min(stimulus);
% stimulus = 0.1+stimulus-stimulusMin;
% runTime = length(stimulus)*StepSize; % ms
% StepSize = 1;               % ms
% NSteps = runTime ./ StepSize;

% short snippet of pink noise
% StepSize = 1;                % ms
% stimulus = zeros(5000,1);
% rng(10); % set random seed
% cn = dsp.ColoredNoise('Color','pink','SamplesPerFrame',length(stimulus));
% noise = cn();
% stimulus = stimulus + (0.8*noise);
% baseline = zeros(1200, 1);
% stimulus = [baseline;stimulus];
% StimulusOnset = length(baseline);
% stimulusMin = min(stimulus);
% stimulus = 0.1+stimulus-stimulusMin;
% runTime = length(stimulus)*StepSize; % ms
% StepSize = 1;               % ms
% NSteps = runTime ./ StepSize;

% pink noise on positive and negative steps
% StepSize = 1;                % ms
% stimulusEpochLength = 1000;
% stimulus0 = zeros(stimulusEpochLength,1);
% stimulus1 = ones(stimulusEpochLength,1);
% stimulusneg1 = -stimulus1;
% stimulus = [stimulus0;stimulus1;stimulus0;stimulusneg1];
% rng(7); % set random seed
% cn = dsp.ColoredNoise('Color','pink','SamplesPerFrame',length(stimulus));
% noise = cn();
% stimulusA = stimulus + (0.05*noise);
% stimulus = [stimulusneg1;stimulus0;stimulus1;stimulus0];
% rng(8); % set random seed
% cn = dsp.ColoredNoise('Color','pink','SamplesPerFrame',length(stimulus));
% noise = cn();
% stimulusB = stimulus + (0.3*noise);
% baseline = zeros(1200, 1);
% stimulus = [baseline;stimulusA;stimulusB];
% StimulusOnset = length(baseline);
% stimulusMin = min(stimulus);
% stimulus = 0.1+stimulus-stimulusMin;
% runTime = length(stimulus)*StepSize; % ms
% StepSize = 1;               % ms
% NSteps = runTime ./ StepSize;

% fast and slow switching
% runTime = 3000;              % ms (default runTime)
% StepSize = 1;                % ms
% NSteps = runTime ./ StepSize;
% stimulus1down = ones(NSteps/40, 1);
% stimulus1up = stimulus1down+10;
% stimulus1 = [stimulus1down;stimulus1up];
% stimulus2down = ones(NSteps/8, 1);
% stimulus2up = stimulus2down+10;
% stimulus2 = [stimulus2down;stimulus2up];
% stimulushalf = [stimulus1;stimulus1;stimulus1;stimulus1;stimulus1;stimulus1;stimulus1;stimulus1;stimulus1;stimulus1;stimulus2;stimulus2];
% stimulus = [stimulushalf;stimulushalf];

% sine wave (runTime will adjust automatically)
% runTime = 500;              % ms (default runTime)
% StepSize = 1;                % ms
% NSteps = runTime ./ StepSize;
% F = 10;                   % sine wave frequency (cycles/s)
% period = 1000 ./ F;         % period (ms/cycle)
% runTime = (round(runTime ./ period))*period; % pads RoundTime so there are an integer number of cycles
% t = (0:StepSize:runTime-StepSize)';   % ms
% stimulus = sin(2*pi*(F/1000)*t);
% stimulus(stimulus<0) = 0;
% stimulus = stimulus+1;
% stimulus = [ones(2000, 1);stimulus;ones(200, 1);stimulus];
% stimulus = stimulus*10;
% NSteps = length(stimulus);
% runTime = StepSize*NSteps; % adjusts runTime

% family of sine waves at diff frequencies (runTime will adjust automatically)
% runTime = 2000;              % ms (default runTime)
% StepSize = 1;                % ms
% NSteps = runTime ./ StepSize;
% sineFrequencies = [.5 3 20]; % these are the frequencies in the sine wave (in Hz)
% epochLength = runTime/length(sineFrequencies);
% sineIndex = 1;
% while sineIndex<=length(sineFrequencies)
%     F = sineFrequencies(sineIndex);                   
%     period = 1000 ./ F; % ms      
%     epochLength = (ceil(epochLength ./ period)) * period; % integer number of cycles
%     t = (0:StepSize:epochLength-StepSize)';
%     sineWave = sin(2*pi*(F/1000)* t);
%     rectifyIndex = sineWave < 0;
%     sineWave(rectifyIndex) = 0;  % rectify
%     if sineIndex == 1
%         stimulus = sineWave;
%     else
%         stimulus = [stimulus;sineWave];
%     end
%     sineIndex = sineIndex+1;
% end
% stimulus = stimulus+1;
% baseline = ones(1000, 1);
% stimulus = [baseline;stimulus];
% stimulus = stimulus*10;
% NSteps = length(stimulus);
% runTime = StepSize*NSteps; % adjusts runTime
% StimulusOnset = length(baseline)*StepSize; % ms

% family of sine waves at diff amplitudes (runTime will adjust automatically)
% SineStimTime = 1000;         % ms
% StepSize = 1;                % ms
% F = 10;                   % sine wave frequency (cycles/s)
% period = 1000 ./ F;         % period (ms/cycle)
% SineStimTime = (round(SineStimTime ./ period))*period; % pads SineStimTime so there are an integer number of cycles
% t = (0:StepSize:SineStimTime-StepSize)';   % ms
% stimulus = sin(2*pi*(F/1000)*t);
% baseline = zeros(2000, 1);
% stimulus = [baseline;stimulus;stimulus*10;stimulus];
% stimulus = stimulus+abs(min(stimulus));
% NSteps = length(stimulus);
% runTime = length(stimulus)*StepSize; % adjusts runTime
% StimulusOnset = length(baseline)*StepSize; % ms
%% Define cells used in this particular run
runCellList = [2:19]; % start with 2 and always include ORNs (but not the stimulus, which is 1)

%% Initialize and set timing variables
sampRate = 1000; % 1000 samples/s. Should not change. 
stepSize = (1 / sampRate) * 1e3; % Size (in ms) of each time step

timeStep = 1;   % Sample at which to initialize model
runTime = length(stimulus); % Model run time (in samples)
%% Set free parameters
LNtoPNScalar = 0; % values <1 weaken the effect of postsynaptic inhibition onto PNs
LNtoLNScalar = .05; % values <1 weaken the effect of postsynaptic inhibition onto LNs
PNtoLNScalar = .05; % values <1 weaken the effect of PN->LN connections
DepletionRate = 0.0073; % per "release unit" (intermediate between fast and slow values from Nagel et al. 2015, i.e. 0.23 and 0.0073)
TauReplenishment = 1000; %  ms (from Nagel et al. 2015)
preInhibitionScalar = .01; % hand-tuned to adjust strength of presynaptic inhibition
ReleaseImpactScalar = 0.01; % hand-tuned; this factor scales the impact of ORN release on target cells to scale overall input to network
taus = zeros(1,19); % time constants for each object
taus(2:3) = 15; % ORN time constants
taus(19) = 15; % PN time constants
taus(4:18) = 15; % LN time constants
biases = zeros(1,19); % neuron-specific biases (effects of leak conductances or spike thresholds)
%% Name objects
objectLabels = {'stimulus' 'ORNipsi' 'ORNcontra' 'LN-A' 'LN-B' 'LN-C' 'LN-D' 'LN-E' 'LN-F' 'LN-G' 'LN-H' 'LN-I' 'LN-J' 'LN-K' 'LN-L' 'LN-M' 'LN-N' 'LN-O' 'PN'};
nNeurons = length(objectLabels);  % Number of objects in network
if ((nNeurons ~= length(taus)) || (nNeurons ~= length(biases)))
    disp('error')
    pause
end

% Manipulate adjacency matrix
thisRunAdjMat = adjMat; % copies adjacency matrix into a temporary matrix used for this run
thisRunAdjMat(4:18,:) = - thisRunAdjMat(4:18,:); % make LN outputs negative
thisRunAdjMat(4:18,19) = thisRunAdjMat(4:18,19) * LNtoPNScalar;
thisRunAdjMat(4:18,4:18) = thisRunAdjMat(4:18,4:18) * LNtoLNScalar;
thisRunAdjMat(19,4:18) = thisRunAdjMat(19,4:18) * PNtoLNScalar;

% Removes connections among LNs
% thisRunAdjMat(4:18,4:18) = 0;

% % Creates new mega-LN
% objectLabels = [objectLabels 'megaLN'];
% nNeurons = length(objectLabels);  % Number of objects in network
% taus = [taus 15]; % adds a tau for the mega-LN
% biases = [biases 0]; % adds a bias for the mega-LN
% MeanInputsToLNs = sum(thisRunAdjMat(4:18,:))/15; % row vector
% thisRunAdjMat = [thisRunAdjMat;MeanInputsToLNs]; % vertically concatenate new row
% ThisRunAdjMatTransp = thisRunAdjMat';
% sumOfOutputsOfLNs = sum(ThisRunAdjMatTransp(4:18,:))';
% thisRunAdjMat = [thisRunAdjMat sumOfOutputsOfLNs]; % horizontally concatenate new column
% thisRunAdjMat(20,20)=0; % zeros self-inputs of mega-LN
% depCon = [depCon; 2 20; 3 20];
% preCon = [preCon; 20 2; 20 3];

% Create matrices to identify depleting connections and presynaptic inhibition
isDep = false(nNeurons, nNeurons); % make logical matrix of zeroes
isPre = false(nNeurons, nNeurons); % make logical matrix of zeroes
isDep(sub2ind(size(isDep), depCon(:,1), depCon(:,2))) = 1; % assign 1 to depleting connections
isPre(sub2ind(size(isPre), preCon(:,1), preCon(:,2))) = 1; % assign 1 to presynaptic inhibition connections

% Omits objects not used in this particular run
for iN=2:nNeurons % for all cells (omitting stimulus index)
    if (ismember(iN,runCellList) == 0) % if cell should not be included in run
        thisRunAdjMat(iN,:)=0; % zero that cell's inputs
        thisRunAdjMat(:,iN)=0; % zero that cell's outputs
    end
end

% % Sets each cell's total input weights equal to one
% for iN=runCellList
%     sumOfInputWeights = sum(thisRunAdjMat(:,iN)); % summed values for this column
%     thisRunAdjMat(:,iN) = thisRunAdjMat(:,iN) / sumOfInputWeights; % divide this column by its sum
% end

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
% for iN = 1:length(nn)
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
        if (iN>=4) % for PN and LNs
            nn(iN).calcRectifiedFR(timeStep);
        else % for ORNs
            nn(iN).calcLinearFR(timeStep);
        end
        
%         saturate PN firing rate
%         if (iN==3)
%             nn(iN).calcSaturatedFR(timeStep);
%         end
        
        % calculate Rel ("release units"/s)
        if ((iN==2)||(iN==3)) % for ORN only
            nn(iN).calcRel(inputActivity, timeStep, isPre(:, iN), StimulusOnset);
        end
        
        % assign calculated values to network outputs
        networkFR(iN, timeStep) = nn(iN).FR(timeStep);
        networkReleaseImpact(iN, timeStep) = nn(iN).Rel(timeStep) * ReleaseImpactScalar;
    end
end

networkActivity = inputActivity;
networkOutput = networkActivity(:,1000:runTime-2);

% add PN noise
rng(1); % set random seed
PNresponse = networkOutput(19,:);
cn = dsp.ColoredNoise('Color','white','SamplesPerFrame',length(PNresponse));
noise = (cn() * 0.05 * (max(PNresponse) - min(PNresponse)))';
networkOutput(19,:) = PNresponse + noise;
%% Plot network output
plotList = [19]; % lists neurons to plot in this simulation

figure;
subplot(2,1,1);
plot(networkOutput(1,:)','linewidth',1,'color','black');
axis tight;
ylim([0 max(networkOutput(1,:))]);
subplot(2,1,2);
hold on;
for iN = (plotList)  % neurons to plot
    if (iN == 19)
        plot(networkOutput(iN,:)','linewidth',1,'color','black');
    else
        plot(networkOutput(iN,:)','linewidth',1);
    end
end
axis tight;
% ylim([0 28]);
% legend(objectLabels(plotList), 'location', 'northeast'); % labels to plot
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
figure
stimulusLevels = [0 stimulusLevels]; % add baseline point
for i=1:9
    SteadyStatePNresp(i) = mean(networkOutput(19,(400+(i*500)):(499+(i*500))));
end
SteadyStatePNresp = SteadyStatePNresp / max(SteadyStatePNresp);
plot(stimulusLevels,SteadyStatePNresp, 'linewidth',2,'color', 'black');
set(gca,'XLim',[0 max(stimulusLevels)],'XTick',[0 100 200 300]);
set(gca,'YLim',[0 1],'YTick',[0 1]);
