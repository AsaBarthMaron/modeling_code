classdef Stim
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
        
    end
    
end

%% Create stimulus                
