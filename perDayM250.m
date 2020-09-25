close all; clearvars -except allMiceData mouseMat
filteredDat = mouseMat;

list = {'155','160','192','222','123','136','159','160b','161','144','145','142' };

uniDays = unique(mouseMat(:,1));
i=0;
for a= [1 2 3 4 5 6 8 9 10 11 12 13]
        i=i+1

    dayMat = mouseMat(mouseMat(:,1) == a,:);
    dayRT(i) = mean(dayMat(:,3));
    
    dayCorrect(i) = mean(dayMat(:,2));
    
    dayTrials(i) = size(dayMat,1);

end

figure(1)
% subplot(2,1,1)

plot(1:length(dayCorrect),dayRT,'m','LineWidth',2)
ax = gca
ax.YColor = 'm';
hold on
scatter(1:length(dayCorrect),dayRT,'.m')
l1 = lsline
l1.Color = 'm';

ylabel('Reaction Time (s)')
xticks([1:12])
xlabel('Day of Training')

hold on
xlim([ -0.5 12.5] )

yyaxis right
plot(1:length(dayCorrect),dayCorrect*100,'b','LineWidth',2)
scatter(1:length(dayCorrect),dayCorrect*100,'.b')
l2 = lsline
l2.Color = 'b';
ylim([0 100])
xlim([ -0.5 12.5] )
ylabel('% Correct')
% yline(50)
title('Mouse 250 training progress')

subplot(2,1,2)
plot(dayTrials,'k')
ylim([0 max(dayTrials)+50])
lsline