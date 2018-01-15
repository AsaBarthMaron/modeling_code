classdef Neuron < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name            % Neuron name
        TimeStep        % Current time step, t
        StepSize        % Length of each TimeStep, units in ms
        NSteps          % # of time steps
        RunTime         % Duration of trial run
        Tau             % Time constant of neuron
        TauKrn          % Exponential decay kernel
        Inputs          % Connection weights from other neurons in Network
        InputResponse   % Integrated synaptic responses, could be as simple as a linear combination. Proxy for subthreshold 
        Response        % Output response of the neuron, proxy for firing rate
    end
    
    methods
        
        function n = Neuron()
            % DEFAULT CONSTRUCTOR creates a Neuron object n
            % n = Neuron()
            n.Name = {};
            n.TimeStep = 1;     % 
            n.StepSize = 1;     % in ms
            n.RunTime = 1000;   % in ms
            n.NSteps = n.RunTime ./ n.StepSize;
            n.Tau = 15;
            n.TauKrn = exp((1:300)/n.Tau);
            n.TauKrn = n.TauKrn ./ max(n.TauKrn);
            n.Inputs = [];
            n.InputResponse = zeros(n.NSteps, 1);
            n.Response = zeros(n.NSteps, 1);
        end
        
        function n = sumInputs(n, networkActivity, timeStep)
            %  SUMINPUTS does a dot product of networkActivity and
            %  n.Inputs to calculate a linear input resposne
            n.Response(timeStep) = n.Inputs' * networkActivity(:, timeStep -1);
        end
        
        function n = leakyIntegrate(n, networkActivity, timeStep)
            %  LEAKYINTEGRATE calculates Response using decay time constant
            %  Tau
            linearInput = networkActivity(:, timeStep-length(n.TauKrn):timeStep-1) .* n.Inputs;
            n.Response(timeStep) =  sum(linearInput * n.TauKrn');
        end
            
        function n = rectify(n, timeStep)
            if n.Response(timeStep) < 0
                n.Response(timeStep) = 0;
            end
        end
    end
end

