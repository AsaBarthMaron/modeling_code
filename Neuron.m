classdef Neuron < handle
% this template describes the elements that are common to all objects
    
    properties
        Name                % Name of object
        TimeStep            % Current time step
        StepSize            % Length of each TimeStep (ms)
        NSteps              % # of time steps
        runTime             % Duration of run
        Tau                 % Time constant of object
        TauKrn              % Dynamics kernel
        Inputs              % Input weights
        SummedInput         % Summed and filtered synaptic inputs (a.u.)
        FR                  % Firing rate (spikes/s)
        Rel                 % Synaptic release ("release units"/s)
        DepletionRate       % Rate of synaptic resource depletion (per "release unit"; note that Depletion Rate*Rel should have units of per s)
        TauReplenishment    % Time constant of synaptic resource replenishment (ms)
        SynResources        % Synaptic resources, A (unitless)
        preInhibitionScalar % Scales the divisive effect of presynaptic inhibition on release
        preInhibitionOverTime % history of the magnitude of presynaptic inhibition
    end
    
    methods
        
        function n = Neuron(runTime, StepSize, NSteps, DepletionRate, TauReplenishment, preInhibitionScalar) % creates object
            n.Name = {};
            n.TimeStep = 1;  
            n.StepSize = StepSize; % ms
            n.runTime = runTime; % ms
            n.NSteps = NSteps;
            n.Inputs = [];
            n.SummedInput = zeros(n.NSteps, 1); % a.u.
            n.FR = zeros(n.NSteps, 1); % spikes/s
            n.Rel = zeros(n.NSteps, 1);% "release units"/s
            n.SynResources = ones(n.NSteps, 1); % unitless
            n.DepletionRate = DepletionRate; 
            n.TauReplenishment = TauReplenishment; 
            n.preInhibitionScalar = preInhibitionScalar; 
            n.preInhibitionOverTime = zeros(n.NSteps, 1); % a.u.
        end
        
        function n = calcSummedInput(n, networkActivity, timeStep, notPre) %  sums synaptic inputs and filters with TauKrn
            filteredInput =  networkActivity(:, timeStep-length(n.TauKrn):timeStep-1).* n.TauKrn;
            filteredInput = sum(filteredInput, 2);
            n.SummedInput(timeStep) = n.Inputs(notPre)' * filteredInput(notPre);
        end
        
        function n = calcLinearFR(n, timeStep)
            n.FR(timeStep) = n.SummedInput(timeStep);
        end
        
        function n = calcRectifiedFR(n, timeStep)
            if (n.SummedInput(timeStep)<0)
                 n.FR(timeStep) = 0;
            else
                n.FR(timeStep) = n.SummedInput(timeStep);
            end
        end
        
        function n = calcRel (n, networkActivity, timeStep, isPre, StimulusOnset) %#ok<INUSD> % calculates Release (from depressing synapses)
            n.Rel(timeStep) = n.FR(timeStep); % first, without presynaptic inhibition, assigns one "release unit" per spike
            filteredInput =  networkActivity(:, timeStep-length(n.TauKrn):timeStep-1).* n.TauKrn; % weight recent activity using filter
            filteredInput = sum(filteredInput, 2); % sum over time, with one value per object
            preInhibition = abs(n.Inputs(isPre))' * filteredInput(isPre); % take synaptic weights from adjMat that represent presynaptic inhibition and multiply by filteredInput
            preInhibition = n.preInhibitionScalar * preInhibition;
%             n.preInhibitionOverTime(timeStep) = preInhibition; % for non-dynamic inhibition (fixes inhibition at baseline)
%             if (timeStep>StimulusOnset-1)
%                 preInhibition = mean(n.preInhibitionOverTime((StimulusOnset-300):(StimulusOnset-1)));
%             end
            if preInhibition > 1 % now let presynaptic inhibition decrease release
                n.Rel(timeStep) = n.Rel(timeStep) ./ preInhibition;
            else
                n.Rel(timeStep) = n.Rel(timeStep);
            end
            Y = exp(cumtrapz((n.DepletionRate .* n.Rel(1:timeStep)) + (1/n.TauReplenishment))); %  % now calculate the synaptic resources (A(t), unitless); begin by exponentiating integral of d*r(t)+(1/Ta) = DepletionRate*Rel+(1/TauReplenishment)
            Y(Y == Inf) = realmax; % deals with cases where y is inf; here y is pegged to max that can be coded
            A = (cumtrapz(Y) ./ (Y .* n.TauReplenishment)) + (1 ./ Y);
            A(isnan(A)) = 0; % deals with cases where A = NaN
            n.SynResources = A;
            n.Rel(timeStep) = n.Rel(timeStep) * n.SynResources(timeStep); % scale release by SynResources
        end            
    end
end
