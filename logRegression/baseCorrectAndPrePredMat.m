%% prep data for R logistic regression model
close all; clear all
% load pre arranged struct
load dataTrialsReward.mat

% loop over days
allPupSize = [];allCorrBasePupSize=[];allBasePupSize=[];allCorrPupSize=[];allCorrect=[];allTrialDiff=[];allRT = [];allLick=[];
allRewSize = [];allContrast = [];
for dayInd = 1:length(dayExp)
    
    % here we make big matrix with all trials all sessions
    pupSize = dayExp(dayInd).dlcData.pupilSize;
    trialDifficulty = abs(dayExp(dayInd).expData(:,3));
    licking = dayExp(dayInd).dlcData.lick;
    RT = dayExp(dayInd).expData(:,4);
    contrast = dayExp(dayInd).expData(:,5); 
    rewSize = dayExp(dayInd).expData(:,6);     
        
        % exp variables
    allRT =[allRT; RT];
        allTrialDiff = [allTrialDiff;trialDifficulty];
    
    allContrast = [allContrast; contrast]
    allRewSize = [allRewSize; rewSize];
    
    % licking
    allLick = [allLick; licking];
    
    % pupil stuff
    allPupSize = [allPupSize; pupSize];
    sessionOnsets(dayInd) = length(allPupSize);
    % get the baseline pupil for all trials
    basePupSize = mean(pupSize(:,base-30:base),2);
    allBasePupSize = [allBasePupSize;basePupSize];

    % get mean of only correct trials of basePupSize
    correct = logical(dayExp(dayInd).expData(:,2));
    corrPupSize = zscore(pupSize,0,'all');
    corrBasePupSize = mean(corrPupSize(:,base-30:base),2);
    
    % here we place the per session corrected matrix by subtracting mean
    % baseline pupil size in CORRECT TRIALS ONLY
    allCorrBasePupSize = [allCorrBasePupSize ; corrBasePupSize];
    allCorrPupSize = [allCorrPupSize; corrPupSize];
    allCorrect = [allCorrect; correct];
    

    %     % to check each session uncomment
    %         subplot(2,length(dayExp),dayInd)
    %         imagesc(pupSize)
    %         title('raw')
    %         subplot(2,length(dayExp),length(dayExp)+dayInd)
    %         imagesc(corrPupSize)
    %         title('corrected')
    
end

%% %% FOR PLOTTING
close all
% plot means for correct vs incorrect for all difficulties
unDiffs = unique(allTrialDiff); unDiffs(unDiffs == 10) = [];

for a = 1:length(unDiffs)
    
    selAngleDiff = unDiffs(a);
    meanCorrect = mean(allCorrPupSize(logical(allCorrect) & allTrialDiff == selAngleDiff,:),1);
    meanIncorrect = mean(allCorrPupSize(~logical(allCorrect) & allTrialDiff == selAngleDiff,:),1);
    
    meanBaseCorrect = mean(allCorrBasePupSize(logical(allCorrect) & allTrialDiff == selAngleDiff,:),1);
    meanBaseIncorrect = mean(allCorrBasePupSize(~logical(allCorrect) & allTrialDiff == selAngleDiff,:),1);
    meanBaseDiff(a) = meanBaseCorrect-meanBaseIncorrect;
    
    seCorrect = std(allCorrPupSize(logical(allCorrect),:),0,1)/sqrt(length(allCorrPupSize(logical(allCorrect),:)));
    seIncorrect = std(allCorrPupSize(~logical(allCorrect),:),0,1)/sqrt(length(allCorrPupSize(~logical(allCorrect),:)));
    
    % plot means for correct vs incorrect for all difficulties
    figure(1)
    subplot(1,9,a)
    shadedErrorBar(((1:length(meanCorrect))-base)/60,meanIncorrect,2*seCorrect,'lineProps','r')
    hold on
    shadedErrorBar(((1:length(meanCorrect))-base)/60,meanCorrect,2*seCorrect,'lineProps','g')
    hold on
    xline(0,'r')
    xlabel('Secs from stim onset')
    ylabel('Z-scored pupil size')
    title(['Angle Diff =' num2str(selAngleDiff),', N = ',num2str(length(allCorrPupSize(logical(allCorrect) & allTrialDiff == selAngleDiff,:)))])
    ylim([-1,1])
    xlim([-1 2])
    
    figure(2)
    hold on
    plot(((1:length(meanCorrect))-base)/60,meanIncorrect-meanCorrect,'Color',[0.11 0.11 0.11]*a)
    hold on
    yline(0)
    ylabel('Mean incorrect trials - mean correct trials')
    xline(0)
    title('Subtracting mean of correct from mean of incorrect per diff')
end


%% plot scatter of baseline pupil difference between correct and incorrect
figure(3)
scatter(1:length(unDiffs)-1,meanBaseDiff(1:end-1))
lsline
title('Pupil size difference, correct incorrect, vs difficulty')
ylabel('Baseline pupil correct - baseline pupil incorrect')
xlabel('Angle Differences')
xticklabels(unDiffs(1:end-1))
xlim([ 0 9])

%% Save data for R
% cd RModelling
% allTrialDiff = zscore(allTrialDiff);
save('pupilForRegress.mat','allCorrPupSize','allCorrBasePupSize','allCorrect','allRT','allTrialDiff','unDiffs','base','allLick','allRewSize','allContrast')

% data = table(allCorrBasePupSize





