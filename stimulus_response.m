stimRate = 50;
% stimImpulse = [sin([1:1:300]/100) + 1]';
%%
rates = 10:10:200;
nRates = length(rates);
for iStim = 1:nRates
    stimImpulse = ones(500,1) * rates(iStim);
    networkActivity = run_network(stimImpulse, stimRate);
    pnResp(:, iStim) = networkActivity(3,:)';
end
%%
plot(1000:3500, pnResp(1000:end, :), 'linewidth', 2)
set(gca, 'box', 'off', 'fontsize', 20)
maxPNresp(3,:) = max(pnResp(1500:end,:));
steadyPNresp(3,:) = mean(pnResp(2400:2500,:));

%%
% stimImpulse = make_stim(.5, stimRate);
% 
% freqs = 1e-1:1e-1:1;
% nFreqs = length(freqs);
% for iStim = 1:nFreqs
%     networkActivity = run_network(stimImpulse, stimRate);
%     pnResp(:, iStim) = networkActivity(3,:)';
% end
% 
% function stimImpulse = make_stim(F, stimRate)
% fs = 1000; % Sampling frequency (samples per second) 
% dt = 1/fs; % seconds per sample 
% StopTime = 1; % seconds 
% t = (0:dt:StopTime)'; % seconds 
% stimImpulse = cos(2*pi*F*t);
% stimImpulse = (((stimImpulse * -1) + 1) * stimRate/2) + 10;
% end
%%
figure
plot(rates, maxPNresp, 'linewidth', 2)
% plot(rates, maxPNresp, 'r', 'linewidth', 2)
set(gca, 'box', 'off', 'fontsize', 20)
hold on
% plot(rates, maxPNresp, 'b*', 'markersize', 20, 'linewidth', 2)
 xlabel('stimulus rate')
ylabel('max PN response')
legend({'ctrl', '-LN1', '-LN2', '-LN1&2'}, 'location', 'west')
%%
figure
plot(rates, steadyPNresp, 'linewidth', 2)
% plot(rates, steadyPNresp, 'r', 'linewidth', 2)
set(gca, 'box', 'off', 'fontsize', 20)
hold on
% plot(rates, steadyPNresp, 'b*', 'markersize', 20, 'linewidth', 2)
 xlabel('stimulus rate')
ylabel('max PN response')
legend({'ctrl', '-LN1', '-LN2', '-LN1&2'}, 'location', 'east')
