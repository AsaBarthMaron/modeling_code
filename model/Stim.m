classdef Stim < handle
    % Class to define stimuli to run the model on
    properties
        Stimulus
    end
    
    methods
        function s = Stim()
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
            s.Stimulus = stimulus;

        end
        
                
%         function s = initializeNetwork TODO
%         end
        function s = varStim(s, iStim)
            sampRate = 1e3; % By design of the model
            s.Stimulus = [];
            
            imp{1} = [ones((0.02 * sampRate),1)*1; zeros((0.08 * sampRate),1)];
            imp{2} = [ones((0.2 * sampRate),1)*1; zeros((0.38 * sampRate),1)];
            imp{3} = [ones((2 * sampRate),1)*1; zeros((1.58 * sampRate),1)];

            stim(:,1) = [zeros(2 * sampRate, 1); repmat(imp{1}, 60, 1); zeros(3 * sampRate, 1)];
            stim(:,2) = [zeros(2 * sampRate, 1);  repmat(imp{2}, 10,1); zeros(3.2 * sampRate, 1)];
            stim(:,3) = [zeros(2 * sampRate, 1);   repmat(imp{3}, 2, 1); zeros(ceil(1.84 * sampRate), 1)];
            
            s.Stimulus = stim(:,iStim) * 1;
        end
    end
end

%% Create stimulus                
