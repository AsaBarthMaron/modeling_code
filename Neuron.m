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
        
        function n = ornInputs(n, networkActivity, timeStep)
            %  SUMINPUTS does a dot product of networkActivity and
            %  n.Inputs to calculate a linear input resposne
            n.Vm(timeStep) = n.Inputs(1)' * networkActivity(1, timeStep -1);
            inhibition = n.Inputs(4:5)' * networkActivity(4:5, timeStep -1);
            n.Vm(timeStep) = n.Vm(timeStep) ./ inhibition;
        end
        
        function n = tauIntegrate(n, networkActivity, timeStep)
            %  TAUINTEGRATE filters Vm using time constant Tau
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
            Y = exp(cumtrapz((n.DepletionRate .* n.FR(1:timeStep)) + (1/n.TauRepleneshment)));
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

