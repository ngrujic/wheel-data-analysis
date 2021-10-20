 %% load data
clear all
load pupilForRegress.mat

% response variable
allCorrect(allCorrect == 0) = -1;
y = categorical(allCorrect);
allTrialDiff = zscore(allTrialDiff);
allContrast = zscore(allContrast);
allRT = zscore(allRT);

% measurements pupil size then diff
predictors = [allCorrBasePupSize allTrialDiff allContrast allRT];

[B,dev,stats] = mnrfit(predictors,y);
betasAndPvals = [B stats.p]

% predicts = mnrval(B,[allCorrBasePupSize allTrialDiff]);

%% Do it in a loop to check which part of pupil size best predicts
binSizeSecs = 0.2;

binSizeSamples = binSizeSecs*60; % change if fps is not 60

moveBy = 0.1*60;
betasAndPvals=[];betasAndPvals2=[];
binPup=[];i=0;
% % logistic regression
% for a = 1+binSizeSamples/2:moveBy:size(allCorrPupSize,2)-binSizeSamples/2
%     i= i+1;
%     binPup(:,i) =  mean(allCorrPupSize(:,a-binSizeSamples/2:a+binSizeSamples/2),2);
%     
%     [B,dev,stats] = mnrfit([binPup(:,i) allTrialDiff],y);
%     betasAndPvals = [betasAndPvals; B(2) stats.p(2)]
%     betasAndPvals2 = [betasAndPvals2; B(3) stats.p(3)]
% end

%% multiple linear regression
weights=[];pVals=[];
i=0;binPup=[];
close all
predNames = {'TrialDiff','Contrast','Correct','RT','allRewSize'}

for a = 1+binSizeSamples/2:moveBy:size(allCorrPupSize,2)-binSizeSamples/2
    i= i+1;
    binPup(:,i) =  mean(allCorrPupSize(:,a-binSizeSamples/2:a+binSizeSamples/2),2);
    
%     tbl = table(allTrialDiff,allContrast,allCorrect,allRT,binPup(:,1), ...
%     'VariableNames',{'TrialDiff','Contrast','Correct','RT','PupSizeBin'});
    predictors = [allTrialDiff,allContrast,allCorrect,allRT,allRewSize];
    
    [b,bint,r,rint,stats] = regress(binPup(:,i),predictors);
    pVals(i) = stats(3);
    weights(:,i) = b;
    
end

figure(1)
subplot(2,1,1)
plot(-0.7+(1:length(weights))/10,weights)
hold on
xline(0,'k')
xlim([-0.75 3])
legend(predNames)

subplot(2,1,2)
plot(-0.7+(1:length(pVals))/10,pVals)
hold on
xline(0,'k')
xlim([-0.75 3])

%% plot the above
close all
figure(1)
plot(-0.7+(1:length(betasAndPvals))/10,betasAndPvals)
title('Predictions of a moving window of pupil size - 200ms')

ylabel('Beta and P values')
xlabel('Seconds from stim onset')
xlim([-0.7, 3])
ylim([-0.3 0.2])
hold on
xline(0,'k')
legend('Beta1','P-val','FontSize',14)

%% plot the above
close all
figure(2)
plot(-0.7+(1:length(betasAndPvals))/10,betasAndPvals2)
title('Predictions of a moving window of pupil size - 200ms')

ylabel('Beta and P values')
xlabel('Seconds from stim onset')
xlim([-0.7, 3])
ylim([-0.3 0.2])
hold on
xline(0,'k')
legend('Beta1','P-val','FontSize',14)

