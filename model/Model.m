classdef Model < Stim & handle
    
    properties
        AbmNames
        AdjMat
        Fname
        ILNs
        IsDep
        IsDiv
        IsFac
        KernType
        Names
        NeuronLabels
        NetworkActivity
        nn
        Param
        RunTime
        SaveDir
        SortedLNcats
        Taus
        TypeInds
    end
    

    methods
        function m = Model()
            % Constructor method
            % Load input variables from a saved workspace.
            % Initialize the properties with loaded defaults.
            % Change defaults later if desired.
            cd '~/Modeling/modeling_code/model'
            inputVars = load('2018-12-15_input_vars.mat');
            m.AbmNames = inputVars.abmNames;
            m.AdjMat = inputVars.adjMat;
            m.ILNs = inputVars.iLNs;
            m.IsDep = inputVars.isDep;
            m.IsDiv = inputVars.isDiv;
            m.IsFac = inputVars.isFac;
            m.KernType = inputVars.kernType;
            m.Names = inputVars.names;
            m.NeuronLabels = inputVars.neuronLabels;
            m.RunTime = size(m.Stimulus,1); % 1st stimulus dimension is always time and sets the model run time
            m.SortedLNcats = inputVars.sortedLNcats;
            m.Taus = inputVars.taus;
            m.TypeInds = inputVars.typeInds;
        end
        
        function m = init(m)
            nNs = length(m.Taus) - 1; % Assumes 1 stimulus dimension
            m.normalizeInputContacts()
            scalingMatrix = ones(nNs, nNs) * 10;
            m.scaleCons(scalingMatrix);
%             m.runExp();
%             m.varStim();
%             m.runVarStim();
%             m.plotResults()
        end
        
%         function m = runModel(m, 
                    
        function m = scaleCons(m, scalingMatrix)
            m.AdjMat(2:end, 2:end) = m.AdjMat(2:end, 2:end) .* scalingMatrix;
        end
        
        function m = initializeModel(m)
            % Run model to steady state
            % Store this model instance, or relevant parameter values so
            % subsequent trials on the same model can be run more quickly.
        end
        
        function m = normalizeInputContacts(m)
            % Assumes 1 stimulus dimension 
            m.AdjMat(2:end, 2:end) = m.AdjMat(2:end, 2:end) ./ sum(abs(m.AdjMat(2:end,2:end)), 1); 
        end
        
        function m = runExp(m, DepletionRate, TauReplenishment)
            [m.NetworkActivity, m.nn] = run_network(m.AdjMat, m.NeuronLabels, m.IsDep, m.IsDiv, m.IsFac, m.Taus, m.KernType, m.Stimulus, m.ILNs(m.TypeInds.y), DepletionRate, TauReplenishment);
        end
        
        function m = runVarStim(m)
            for stimFreq = 1:size(m.Stimulus,2)
                [NetworkActivity, ~] = run_network(m.AdjMat, m.NeuronLabels, m.IsDep, m.IsDiv, m.IsFac, m.Taus, m.KernType, m.Stimulus(:,stimFreq), m.ILNs(m.TypeInds.y));
                m.NetworkActivity(:,:,stimFreq) = squeeze(NetworkActivity);
            end
        end
        
        function m = saveResults(m, fname, saveDir)
%             d = datetime('now', 'format', 'yyyy-MM-dd');
%             fname = [char(d) '_' argString '.mat'];
            saveFile = strcat(fullfile(saveDir, fname), '.mat');
            save(saveFile, 'm');
        end
                
        function plotResults(m)
            xStart = 1000;
            runTime = size(m.Stimulus, 1);
            networkActivity = m.NetworkActivity;
            networkActivity(:, end) = networkActivity(:, end-1);
            neuronLabels = m.NeuronLabels;
            typeInds = m.TypeInds;
            iLNs = m.ILNs;
            
            remLNs = iLNs;
            remLNs([typeInds.y; typeInds.ts; typeInds.d]) = [];
            typeInds.rem = remLNs;
            
            yLims(2) = max(max(networkActivity(4:end, xStart:end)));
            yLims(2) = yLims(2) * 1.05;
            yLims(1) = 0;
            xLims = [xStart runTime];
            
            figure
            subplot(5,1,1)
            plot(xStart:runTime, networkActivity(1,xStart:end)', 'linewidth', 2);
            legend(neuronLabels(1), 'location', 'west')
            set(gca, 'box', 'off', 'fontsize', 26)
            xlim(xLims)
            
            subplot(5,1,2:5)
            thisPlotInds = {typeInds.pn, iLNs(typeInds.y), iLNs(typeInds.ts), iLNs(typeInds.d), typeInds.rem};
            plot(xStart:runTime, networkActivity(thisPlotInds{5},xStart:end)', 'linewidth', 2, 'color', [0.9, 0.9, 0.9])
            hold on
            plot(xStart:runTime, networkActivity(thisPlotInds{4},xStart:end)', 'linewidth', 2, 'color', [0.0, 0.75, 0.75])
            plot(xStart:runTime, networkActivity(thisPlotInds{2},xStart:end)', 'linewidth', 2, 'color', [0.925, 0.69, 0.122])
            plot(xStart:runTime, networkActivity(thisPlotInds{3},xStart:end)', 'linewidth', 2, 'color', [0.49, 0.18, 0.553])
            plot(xStart:runTime, networkActivity(thisPlotInds{1},xStart:end)', 'linewidth', 4, 'color', [0.3, 0.5, 0.35])
            thisPlotLabels = [neuronLabels(thisPlotInds{5}), neuronLabels(thisPlotInds{4}), neuronLabels(thisPlotInds{2}), neuronLabels(thisPlotInds{3}), neuronLabels(thisPlotInds{1})];
            legend(thisPlotLabels, 'location', 'west', 'NumColumns', 3)
            set(gca, 'box', 'off', 'fontsize', 26, 'ylim', yLims)
            xlim(xLims)
            set(gcf, 'position', [0 0 1920 1200])
            ylim(yLims);
            
%             linkaxes('x')
        end
    end
    
end


%     methods(Static)
%         function main()
%             inputVars = '~/Modeling/modeling_code/2018-12-15_input_vars.mat';
%             m = Model(inputVars)
%         end
%     end
%     
