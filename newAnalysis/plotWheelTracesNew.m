
for a = 1:length(displacementWholeTrials)
    trialsRespLength(a) = length(displacementWholeTrials{1,a});
end
longestTrialSize = max(trialsRespLength);
for a = 1:length(displacementWholeTrials)
    currTrial(a,:) = [displacementWholeTrials{1,a}(1:60)-displacementWholeTrials{1,a}(1) ...
        displacementWholeTrials{1,a}(61:end)-100000 NaN(1,longestTrialSize - trialsRespLength(a))];
end

for a = 1:length(displacementWholeTrials)
    hold on
    
    if correct(a) == 1
       lineType = '--';
    else
        lineType = ':';
    end
    if response(a) == -1
       col = 'b';
    else
        col = 'r';
    end
plot(((1:length(currTrial(a,:)))-30)./60,currTrial(a,:),lineType,'Color',col)



end
close all
figure
subplot(2,1,1)
corrTrialMeanL = median(currTrial((logical(correct) & response == -1),:),1)
corrTrialMeanR = median(currTrial((logical(correct) & response == 1),:),1)
incorrTrialMeanL = median(currTrial((~logical(correct) & response == -1),:),1)
incorrTrialMeanR = median(currTrial((~logical(correct) & response == 1),:),1)



plot(((1:length(corrTrialMeanL))-30)./60,corrTrialMeanL,'Color','b')
hold on
plot(((1:length(corrTrialMeanR))-30)./60,corrTrialMeanR,'Color','r')
hold on
plot(((1:length(incorrTrialMeanL))-30)./60,incorrTrialMeanL,'--','Color','b')
hold on
plot(((1:length(incorrTrialMeanR))-30)./60,incorrTrialMeanR,'--','Color','r')

hold on
yline(36)
hold on
yline(-36)
hold on
xline(0)
hold on
xline(0.5)
ylim([-50 50]);xlim([-0.5 3])
yticks([-36,0,36])
yticklabels({'Resp Threshold','Wheel Trace','Resp Threshold'})
title('MEDIAN of Correct, Incorrect for two sides')

subplot(2,1,2)
corrTrialMeanL = mean(currTrial((logical(correct) & response == -1),:),1)
corrTrialMeanR = mean(currTrial((logical(correct) & response == 1),:),1)
incorrTrialMeanL = mean(currTrial((~logical(correct) & response == -1),:),1)
incorrTrialMeanR = mean(currTrial((~logical(correct) & response == 1),:),1)


plot(((1:length(corrTrialMeanL))-30)./60,corrTrialMeanL,'Color','b')
hold on
plot(((1:length(corrTrialMeanR))-30)./60,corrTrialMeanR,'Color','r')
hold on
plot(((1:length(incorrTrialMeanL))-30)./60,incorrTrialMeanL,'--','Color','b')
hold on
plot(((1:length(incorrTrialMeanR))-30)./60,incorrTrialMeanR,'--','Color','r')

hold on
yline(36)
hold on
yline(-36)
hold on
xline(0)
hold on
xline(0.5)
ylim([-50 50]);xlim([-0.5 3])
yticks([-36,0,36])
yticklabels({'Resp Threshold','Wheel Trace','Resp Threshold'})
title('MEAN of Correct, Incorrect for two sides')
