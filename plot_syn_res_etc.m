%% Synaptic Resources
figure
plot(1:runTime, nn(2).SynRes, 'linewidth', 2)
set(gca, 'fontsize', 20, 'box', 'off')
ylabel('iORN SynRes, [0, 1]')
axis tight
%% Rel
figure
plot(networkRelease(2,:), 'linewidth', 2)
set(gca, 'fontsize', 20, 'box', 'off')
ylabel('iORN Rel, FR(t) * SynRes(t) / inhibition(t)')
axis tight
%%
figure
plot(1./Y, 'linewidth', 2)
set(gca, 'fontsize', 20, 'box', 'off')
ylabel('iORN 1/Y - constant (C)')
axis tight