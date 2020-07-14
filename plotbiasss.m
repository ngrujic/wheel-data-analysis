%% new stims vector in tha makin

%% diagnosis
% reward is 2s after stim onset = 62 frames 
% we have IR light we have running
% 2 seconds quiescent then wait mod(6,nFrame)
% can run after stim onset..
frameLoco1 = frameLoco;
frameLoco2 = frameLoco;
%% plot sum shit
figure(3)
subplot(4,1,1)
plot((1:length(frameIR))/30.9,frameIR)
title('IR light')
subplot(4,1,2)
plot((1:length(frameIR))/30.9,frameLoco1)
title('loco 1')
subplot(4,1,3)
plot((1:length(frameIR))/30.9,frameLoco2)
title('loco 2')
subplot(4,1,4)
plot((1:length(frameIR))/30.9,frameReward)
title('Reward')
xlabel('Seconds')
linkaxes