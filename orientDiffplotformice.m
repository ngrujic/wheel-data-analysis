%% data manipulations categorizing
clear all

%%
% filter trials by different things in conditionIdx
conditionIdx = mouseMat(:,7) ==0;
filteredDat = mouseMat(conditionIdx,:);

% unique mice
uniqueMice = unique(filteredDat(:,1))

% get contrast difference
contrastLR = abs(filteredDat(:,14)-filteredDat(:,13));
contrastsUn = unique(contrastLR);

% orient differences
orientDiff = abs(abs(filteredDat(:,11))-abs(filteredDat(:,12)));
orientDiffUn = unique(abs(orientDiff));
% %
% % % categorize by low = 0.5 medium = 1.5 high = 2.5 prior values
% % highLim = 65;
% % medLim = 35;
% % lowLim = 0;
% % i=0;
% %
% % idxVals = zeros(length(filteredDat),2);
% % for a = 11:12
% %     i = i+1;
% %     lowIdx = abs(filteredDat(:,a))< medLim;
% %     medIdx = abs(filteredDat(:,a))>= medLim & abs(filteredDat(:,a))<= highLim;
% %     highIdx = abs(filteredDat(:,a))>= highLim;
% %
% %     idxVals(lowIdx,i) = 0.5;
% %     idxVals(medIdx,i) = 1.5;
% %     idxVals(highIdx,i) = 2.5;
% %
% % end
% %
% % trialPriorVal = sum(idxVals,2);
% % unPriorVals = unique(trialPriorVal);

%%
figure; clear meanCorrect stdCorr nTrials
for i =1:length(uniqueMice)
    for ii = 1:length(orientDiffUn)
        
        tempDat = filteredDat(filteredDat(:,1) == uniqueMice(i) & orientDiff == orientDiffUn(ii),:);
        %         tempDat = tempDat(size(tempDat,1)/2 : end,:);
        nTrials(ii,i) = size(tempDat,1);
        
        % we include repeated trials in the NTrials calculation
%         tempDat = tempDat(tempDat(:,8)==0,:);
        
        meanCorrect(ii,i) = mean(tempDat(:,3));
        stdCorr(ii,i) = sqrt((meanCorrect(ii,i)*(1-meanCorrect(ii,i)))/nTrials(ii,i));
        
    end
    
%     hold on
%     errorbar(1:length(meanCorrect(:,i)),meanCorrect(:,i),stdCorr(:,i),stdCorr(:,i))
        
end

for i = 1:length(uniqueMice)
    ax(1) =  subplot(1,2,1)
    hold on
    errorbar(1:length(meanCorrect(:,i)),(meanCorrect(:,i)),stdCorr(:,i),stdCorr(:,i))
    
    ax(2) = subplot(1,2,2)
    hold on
    plot(1:length(nTrials(:,i)),(nTrials(:,i)))
end
linkaxes(ax,'x')

    subplot(1,2,1); hold on

meanMean = mean(meanCorrect,2);
seMice = 2*(std(meanCorrect')')./sqrt(length(uniqueMice));

 errorbar(1:length(meanMean),(meanMean),seMice,seMice,'Color','k','LineWidth',2)

ylabel('Proportion Correct')
xticks(1:length(orientDiffUn))
xticklabels(orientDiffUn)
xlabel('Difference in Angle')
yline(0.5)
legend(mice )

subplot(1,2,2)
legend(mice )
ylabel('N Trials')
xticks(1:length(orientDiffUn))
xticklabels(orientDiffUn)
xlabel('Difference in Angle')
%% THIS figure is limiting all orients to only 20 degree difference

orientsDat = filteredDat(:,11:12);
orIdx = find(abs(orientsDat(:,1)) < abs(orientsDat(:,2)));
notOtIdx = find(~(abs(orientsDat(:,1)) < abs(orientsDat(:,2))));
correctOrients = zeros(length(orientsDat),1);

correctOrients(orIdx) = orientsDat(orIdx,1);
correctOrients(notOtIdx) = orientsDat(notOtIdx,2);

correctOrients =(correctOrients);

unCorrectOrients = unique(correctOrients);

% two conditions
clear meanCorrect stdCorr nTrials meanMean seMice
 for a = 1 
    for i = 1:length(uniqueMice)
        
        for ii = 1:length(unCorrectOrients)
            
            tempDat = filteredDat( filteredDat(:,1) == uniqueMice(i) & correctOrients == unCorrectOrients(ii) ...
                & orientDiff >=20  & orientDiff <=40,:);
            
                            nTrials(ii,i) = size(tempDat,1);

            
            if a == 2
            tempDat = tempDat(round(size(tempDat,1)/2)+1:end,:);
            end
        
        % we include repeated trials in the NTrials calculation
        tempDat = tempDat(tempDat(:,8)==0,:);
            
            meanCorrect(ii,i) = mean(tempDat(:,3));
            seCorr(ii,i) = sqrt((meanCorrect(ii,i)*(1-meanCorrect(ii,i)))/nTrials(ii,i));
            
        end
        
    end

figure(a)

for i = 1:length(uniqueMice)
    ax(1) = subplot(1,2,1)
    hold on
    ax1 = errorbar(1:length(meanCorrect(:,i)),(meanCorrect(:,i)),seCorr(:,i),seCorr(:,i))
    
    ax(2) = subplot(1,2,2)
    hold on
    ax2 =  plot(1:length(nTrials(:,i)),(nTrials(:,i)))
end
linkaxes(ax,'x')
subplot(1,2,1)
meanMean(:,a) = mean(meanCorrect,2);
seMice(:,a) = 2*(std(meanCorrect')')./sqrt(length(uniqueMice));

 errorbar(1:length(meanMean(:,a)),(meanMean(:,a)),seMice(:,a),seMice(:,a),'Color','k','LineWidth',2)
ylim([0.5 1])


yline(0.5)
legend(mice )
ylabel('Proportion Correct')
xticks(1:length(unCorrectOrients))
xticklabels(unCorrectOrients)
xlabel('Correct Side Angle')

subplot(1,2,2);legend(mice )
legend(mice )
ylabel('N Trials')
xticks(1:length(unCorrectOrients))
xticklabels(unCorrectOrients)
xlabel('Correct Side Angle')

end
