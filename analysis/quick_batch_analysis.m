clear
cd '/Users/asa/Modeling/modeling_results/2019-03-13_minimal_con_type_param_sweep'

resultFiles = dir();
resultFiles(1:3) = [];

runArgs = struct;
runArgs.stimWav = [];
runArgs.intensity = [];
runArgs.ORNtoLNPN = [];
runArgs.PNtoLNPN = [];
runArgs.LNtoLNPN = [];
runArgs.ORNtoORN = [];
runArgs.LNtoORN = [];
runArgs.PNtoORN = [];
runArgs.ORN = [];
runArgs.LN = [];
runArgs.PN = [];

fields = fieldnames(runArgs);

for iFile = 1:length(resultFiles)
    for iField = 1:length(fields)
        tFn = fields(iField);   % This field name
        tFn = strcat('_',tFn{1}, '-');
        if iField ~= length(fields)
            nFn = fields(iField+1); % Next field name
            nFn = strcat('_',nFn{1}, '-');
        elseif iField == length(fields)
            nFn = {'.mat'};
        end
        
        iVal(1) = strfind(resultFiles(iFile).name, tFn);
        iVal(1) = iVal(1) + length(tFn);
        iVal(2) = strfind(resultFiles(iFile).name, nFn);
        iVal(2) = iVal(2) - 1;
        
        fn = fields(iField);
        runArgs(iFile).(fn{1}) = resultFiles(iFile).name(iVal(1):iVal(2));
        if ~strcmpi(fn{1}, 'stimWav')
            runArgs(iFile).(fn{1}) = str2num(runArgs(iFile).(fn{1}));
        end
    end
end

inds = find(extractfield(runArgs, 'ORNtoLNPN') == 0)

% This is all going to be hard-coded, from looking at the file read in.
% This code is only meant to be a temporary solution anyway.
runArgs = reshape(runArgs, 28, 4);
ctrlArgs = runArgs(26, :);
runArgs(26,:) = [];
tmpArgs(1:4:36, :) = runArgs(1:3:end, :);
tmpArgs(2:4:36, :) = repmat(ctrlArgs, 9, 1);
tmpArgs(3:4:36, :) = runArgs(2:3:end, :);
tmpArgs(4:4:36, :) = runArgs(3:3:end, :);
runArgs = tmpArgs;
runArgs = reshape(runArgs, 4, 9, 4);
runArgs = permute(runArgs, [1 3 2])
clear tmpArgs ctrlArgs

% Dammit now I have to do the same thing for resultFiles
resultFiles = reshape(resultFiles, 28, 4);
ctrlFiles = resultFiles(26, :);
resultFiles(26,:) = [];
tmpFiles(1:4:36, :) = resultFiles(1:3:end, :);
tmpFiles(2:4:36, :) = repmat(ctrlFiles, 9, 1);
tmpFiles(3:4:36, :) = resultFiles(2:3:end, :);
tmpFiles(4:4:36, :) = resultFiles(3:3:end, :);
resultFiles = tmpFiles;
resultFiles = reshape(resultFiles, 4, 9, 4);
resultFiles = permute(resultFiles, [1 3 2])
clear tmpFiles ctrlFiles

for iScalarVal = 1:size(resultFiles,1)
    for iIntensity = 1:size(resultFiles,2)
        for iConType = 1:size(resultFiles,3)
            ldFile = load(resultFiles(iScalarVal, iIntensity, iConType).name);
            m(iScalarVal, iIntensity, iConType) = ldFile.m; % Oof, model is changing the directory :/ should change that
            cd '/Users/asa/Modeling/modeling_results/2019-03-13_minimal_con_type_param_sweep'
        end
    end
end

%% Plot
close all
m = flip(m, 2);
resultFiles = flip(resultFiles,2);
runArgs = flip(runArgs, 2);

for iConType = 1:size(resultFiles,3)
    fn = fields(iConType + 2);
    figure
    subplot(4,4,1)
    for iScalarVal = 1:size(resultFiles,1)
        for iIntensity = 1:size(resultFiles,2)
            iPlot = sub2ind([4, 4], iIntensity, iScalarVal);
            subplot(4,4, iPlot)
            pnFR = m(iScalarVal, iIntensity, iConType).NetworkActivity(53,:);
            plot(pnFR(1e3:(3.5e3-1)), 'linewidth', 1.5)
            set(gca, 'box', 'off', 'fontsize', 20)
        end
    end
    yPlots = 1:4:16;
    for iYPlot = 1:4
        subplot(4,4, yPlots(iYPlot))
        ylabel([fn, runArgs(iYPlot, 1, iConType).(fn{1})]);
    end
    for iXPlot = 1:4
        subplot(4,4, iXPlot)
        title(['Stimulus intensity - ', num2str(runArgs(1, iXPlot, 1).intensity), 'x']);
    end
end


% scalarDict = containers.Map([0 ,1, 10, 100], 1:4);
% intensityDict = containers.Map([1, 10, 100, 1000], 1:4);

% for iFile = 1:length

% m(intensity, [syn params 1-9])
