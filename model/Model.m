classdef Model < Stim
    
    properties
        AbmNames
        AdjMat
        ILNs
        IsDep
        IsDiv
        IsFac
        KernType
        Names
        NeuronLabels
        NetWorkAcvtivity
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
            cd '~/Modeling/modeling_code'
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
            m.SortedLNcats = inputVars.sortedLNcats;
            m.Taus = inputVars.taus;
            m.TypeInds = inputVars.typeInds;
        end
        
        function m = init()
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