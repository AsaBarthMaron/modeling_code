classdef Neuron_old < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name            % Neuron name
        TimeStep        % Current time step, t
        StepSize        % Length of each TimeStep, units in ms
        NSteps          % # of time steps
        RunTime         % Duration of trial run
        Tau             % Time constant of neuron
        TauKrn          % Dynamics kernel
        Inputs          % Connection weights from other neurons in Network
        Vm              % Proxy for subthreshold voltage (not in proper units)
        FR              % Proxy for firing rate (not necessarily in spk/s)
        Rel             % Proxy for synaptic release. The quantity that downstream neurons actually see.
        DepletionRate   % Rate of synaptic resource depletion
        TauRepleneshment% Tau of synaptic resource repleneshment 
        IntegratedFR    % Integral of FR 
        SynRes          % Synaptic resources
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
            n.TauKrn = n.TauKrn ./ sum(n.TauKrn);
            n.Inputs = [];
            n.Vm = zeros(n.NSteps, 1);
            n.FR = zeros(n.NSteps, 1);
            n.Rel = zeros(n.NSteps, 1);
            n.SynRes = ones(n.NSteps, 1);
            n.IntegratedFR = zeros(n.NSteps, 1);
            n.DepletionRate = 0.23 * 1e-3;     % Taken from Kathy's paper, units in terms of fraction per spike
            n.TauRepleneshment = 1000; % Taken from Kathy's paper, units of ms
            
        end
        
        function n = sumInputs(n, networkActivity, timeStep)
            %  SUMINPUTS does a dot product of networkActivity and
            %  n.Inputs to calculate a linear input resposne
            n.Vm(timeStep) = n.Inputs' * networkActivity(:, timeStep -1);
        end
        
        function n = calcResponses(n, networkActivity, timeStep, notDiv)
            %  CALCRESPONSES calculates the responses (Vm) using linear
            %  integration and filters with TauKrn. Inhibitory (input)
            %  connections can be either subtractive or divisive, as 
            %  specified by the logical vector isDiv. 
            filteredInput =  networkActivity(:, timeStep-length(n.TauKrn):timeStep-1)...
                             .* n.TauKrn;
            filteredInput = sum(filteredInput, 2);
            n.Vm(timeStep) = n.Inputs(notDiv)' * filteredInput(notDiv);
        end
        
        function n = divInhibition(n, networkActivity, timeStep, isDiv)
            %  DESCRIPTION GOES HERE
            filteredInput =  networkActivity(:, timeStep-length(n.TauKrn):timeStep-1)...
                             .* n.TauKrn;
            filteredInput = sum(filteredInput, 2);
            inhibition = abs(n.Inputs(isDiv))' * filteredInput(isDiv);
%             if inhibition < 1
%                 inhibition = 1;
%             end
            if inhibition > 0 
                n.Rel(timeStep) = n.Rel(timeStep) ./ inhibition;
            end
        end
        
        function n = tauIntegrate(n, networkActivity, timeStep)
            %  TAUINTEGRATE filters Vm using dynamics kernel TauKrn
            linearInput = bsxfun(@times, ...
                networkActivity(:, timeStep-length(n.TauKrn):timeStep-1),...
                n.Inputs);
            n.Vm(timeStep) =  sum(linearInput * n.TauKrn');
        end
            
        function n = rectify(n, timeStep)
            % RECTIFY does half-wave rectification on Vm to generate FR
            if n.Vm(timeStep) < 0
                n.FR(timeStep) = 0;
            else
                n.FR(timeStep) = n.Vm(timeStep);
            end
        end
        
        function calcResources(n, timeStep)
            % CALCRESOURCES uses methods described in my 2018-01-24
            % evernote note to calculate the synaptic resources
            % First step is to calculate the integral of d*r(t) + (1/Ta)
            % or: DepletionRate * FR + (1/TauRepleneshment)
            Y = exp(cumtrapz((n.DepletionRate .* n.Rel(1:timeStep)) + (1/n.TauRepleneshment)));
            Y(Y == Inf) = realmax;
            LHS = (cumtrapz(Y) ./ (Y .* n.TauRepleneshment)) + (1 ./ Y);
            LHS(isnan(LHS)) = 0;
            n.SynRes = LHS;
        end
        
        function n = saturate(n, timeStep)
            if n.Response(timeStep) > 1
                n.Response(timeStep) = 1;
            end
        end
    end
end