classdef Stim < handle
    % Class to define stimuli to run the model on
    properties
        Baseline
        Intensity
        Stimulus
        StimWav
    end
    
    methods
        function s = Stim()
            s.stepStim(8, 100);
            s.setIntensity(384);
            s.setBaseline(2e3, 20);
            s.addBaseline;
        end
        
        function s = setBaseline(s, len, intensity)
            s.Baseline = ones(len, 1) * intensity;
        end
        
        function s = addBaseline(s)
            % Intensity should be set (setIntensity) before
            % adding baseline. Otherwise setIntensity will 
            % scale the baseline as well.
            
            s.Stimulus = [s.Baseline; s.Stimulus + max(s.Baseline)];
        end
        
        function s = setStimulus(s, stimWav)
            % Takes input string stimWav and selects appropriate stimulus
            % waveform based on results.
            
            switch stimWav
                case 'fast'
                    s.varStim(1);
                case 'med'
                    s.varStim(2);
                case 'slow'
                    s.varStim(3);
                case 'steps'
                    s.stepStim();
                case 'square'
                    s.squarePulse();
            end
        end
        
        function s = stepStim(s, nSteps, stepLen)
            % Note, values using this generator fn will be
            % much larger amplitude than the rest (
            s.Stimulus = [];
            stimLvls = 1.5 * (2.^[1:nSteps]);
            for iLvl = 1:nSteps
                stimStep = ones(stepLen, 1) * stimLvls(iLvl);
                s.Stimulus = [s.Stimulus; stimStep];
            end
           s.Stimulus = s.Stimulus / max(s.Stimulus);
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
            stimWav = {'fast', 'med', 'slow'};
            s.StimWav = stimWav{iStim};
        end
        
        function s = setIntensity(s, intensity)
            s.Stimulus = s.Stimulus .* intensity;
        end
        
        function s = squarePulse(s, len)
            s.Stimulus = [];
            s.Stimulus = [ones(len, 1); zeros(0.5 * len, 1)];
        end
            
    end
end

%% Create stimulus                
