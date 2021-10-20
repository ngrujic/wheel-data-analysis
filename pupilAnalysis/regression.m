%% Code for linear regression of pupil data
% clear all; close all

%% load correct datatrials mat file

direc{2} = "C:\worktemp\Wheel\pupilDat\wrongRewardTask\wrongRewardTask_outliersRemoved_dataTrials.mat"
direc{1} = "C:\worktemp\Wheel\pupilDat\accuracyTask\accuracyTask_outliersRemoved_dataTrials.mat"
direc{3} = "C:\worktemp\Wheel\pupilDat\correctRewardTask\correctRewardTask_outliersRemoved_dataTrials.mat"

weightsMaxResp = []
for iiii = 3
    clearvars -except fic rewardAlign file folder iiii direc allConditionsMaxRespC allConditionsLickC allConditionsLickI weightsMaxResp
    rewardAlign = 0

    load(direc{iiii})


%% Parameters
animals = [123,155,160,192,222];
nDays = length(dayExpTrials);
fs = 60;

% regression parameters
binSize = 0.2*fs;
moveBy = 0.1*fs;

base = 0.75*fs;

%% Loop through animals and arrange trials and pupil data
mouseExpTrials = []; mousePupilTrials = []; mouseLickTrials = []; mousePupilRew = [];
for i = 1:nDays
    
     % get exp data
        expDat = dayExpTrials(i).expData;
        
        % get pupil
        pupilDat = dayExpTrials(i).dlcData.pupilSize;
        
        % get lick
        lickDat = dayExpTrials(i).dlcData.lick;
        
        % Split into disengaged vs engaged trials
        disengageInd = find(expDat(:,11) > 3);
        expDat(:,16) = 0;
        expDat(disengageInd,16) = 1;
        
        % filter out the >3 sec rt trials
        removeInd = find(expDat(:,11) > 3);
        expDat(removeInd,:) = [];
        pupilDat(removeInd,:) = [];
        lickDat(removeInd,:) = [];
        
        % filter out the repeated trials
        removeInd = find(expDat(:,10) == 1);
        expDat(removeInd,:) = [];
        pupilDat(removeInd,:) = [];
        lickDat(removeInd,:) = [];
        
        % filter out the 10 deg trials trials
        removeInd = find(expDat(:,12) == 10);
        expDat(removeInd,:) = [];
        pupilDat(removeInd,:) = [];
        lickDat(removeInd,:) = [];
        
        % filter out the 0 deg trials trials
        removeInd = find(expDat(:,12) == 0);
        expDat(removeInd,:) = [];
        pupilDat(removeInd,:) = [];
        lickDat(removeInd,:) = [];
        
    
    % arrange by reward
    if rewardAlign == 1
        pupilRew = [];lickRew=[];
        for j = 1:size(pupilDat,1)
            pupilRew(j,:) = pupilDat(j,round(expDat(j,11)*fs) + 0.5*fs:base + round(expDat(j,11)*fs) + 0.5*fs + 3*60);
            lickRew(j,:) = lickDat(j,round(expDat(j,11)*fs) + 0.5*fs:base + round(expDat(j,11)*fs) + 0.5*fs + 3*60);

        end
        pupilDat = pupilRew;
        lickDat = lickRew;
    end
    
    
    % add all the trials from one mouse together
    mousePupilTrials = [mousePupilTrials; pupilDat];
    mouseExpTrials = [mouseExpTrials; expDat];
    mouseLickTrials = [ mouseLickTrials; lickDat];
end

%% Loop through animals and run regressions
predNames = {'B0','Trial Diff','CorrectAngle','Correct','Choice1B','lick','prior','prior_x_rew'};
% predNames = {'B0','Trial Diff','Sum Contrast','CorrectAngle','Correct'}
% predNames = {'B0','Trial Diff','Sum Contrast','RT','CorrectAngle'}
% predNames = {'B0','Trial Diff','Sum Contrast','CorrectAngle','Correct','Choice1B','lick'}
predNamesCorr = {'B0','Trial Diff','CorrectAngle','Choice1B','lick','prior','prior_x_rew'};

pupData = [];predictorsAll=[];
for i = 1:length(animals)
    
    oneMouseExp = mouseExpTrials(mouseExpTrials(:,13) == animals(i),:);
    oneMousePup = mousePupilTrials(mouseExpTrials(:,13) == animals(i),:);
    oneMouseLick = mouseLickTrials(mouseExpTrials(:,13) == animals(i),:);
    
    % extract parameters for predictive
    allTrialDiff = zscore(oneMouseExp(:,12));
    allChoice1B = oneMouseExp(:,15); allChoice1B(allChoice1B == 0) = -1;
    allCorrect = oneMouseExp(:,2); allCorrect(allCorrect == 0) = -1;
    allRT = zscore(oneMouseExp(:,11));
    allCorrAng = zscore(min(abs(oneMouseExp(:,5:6)),[],2));

    
    
    
    % mapping rewards and priors
    CA = min(abs(oneMouseExp(:,5:6)),[],2);
    corrAng = hist(min(abs(oneMouseExp(:,5:6)),[],2));
    corrAng(corrAng == 0) = [];
    
    reward = 1:0.8:7
    unCA = unique(CA)

    if iiii == 1
        expVals = corrAng
        iiii
    elseif iiii == 2
        expVals = corrAng.*unCA';
        iiii
    elseif iiii ==3
        expVals = corrAng.*fliplr(unCA');
        iiii
    end
    
allPriorVals = zeros(length(CA),1);
allExpVals = zeros(length(CA),1);

    for a = 1:length(unCA)
       
        allPriorVals(CA == unCA(a)) = corrAng(a);
        allExpVals(CA == unCA(a)) = expVals(a);

        
    end
    
    allPriorVals = zscore(allPriorVals);
        allExpVals = zscore(allExpVals);

    
    
    
        % SUBTRACTING BASELINE 
        for j = 1:size(oneMousePup,1)
            oneMousePup(j,1:end) = (oneMousePup(j,:) - mean(oneMousePup(j,1:base)));
        end  
        

    % loop over the bins
    k = 0;pupilBinned = [];lickBinned = [];pupDat= [];
    for j = 1+binSize/2:moveBy:size(oneMousePup,2)-binSize/2
        k = k+1;
        pupilBinned(:,k) = mean(oneMousePup(:,j-binSize/2:j+binSize/2),2);
        lickBinned(:,k) = mean(oneMouseLick(:,j-binSize/2:j+binSize/2),2);
        
        %% allTrialsTogether
        predictors1 = [ones(length(allTrialDiff),1), allTrialDiff, allCorrAng,...
            allCorrect,allChoice1B, lickBinned(:,k), allPriorVals, allExpVals];
        %         predictors = [ones(length(allTrialDiff),1), allTrialDiff, allContrast, allCorrAng,...
        %             allCorrect,allChoice1B, lickBinned(:,k)];
        
        [b,bint,r,rint,stats] = regress(pupilBinned(:,k),predictors1);
        
        weights(:,k,i) = b;
        
        %% same but for correct
        predictors2 = predictors1(allCorrect == 1,[1 2 3 5 6]);
        
        [b,bint,r,rint,stats] = regress(pupilBinned(allCorrect == 1,k),predictors2);
        
        weightsCorr(:,k,i) = b;
        
        %% same but for incorrect
        predictors3 = predictors1(allCorrect == -1,[1 2 3 5 6]);
        
        [b,bint,r,rint,stats] = regress(pupilBinned(allCorrect == -1,k),predictors3);
        
        weightsInc(:,k,i) = b;
        
    end
     % MEANS PUPIL
    oneMouseMeanPup(i,:) = mean(pupilBinned,1);
    oneMouseMeanLick(i,:) = mean(lickBinned,1);
    oneMouseMeanPupCorr(i,:) = mean(pupilBinned(allCorrect == 1,:),1);
    oneMouseMeanLickCorr(i,:) = mean(lickBinned(allCorrect == 1,:),1);
    oneMouseMeanPupInc(i,:) = mean(pupilBinned(allCorrect == -1,:),1);
    oneMouseMeanLickInc(i,:) = mean(lickBinned(allCorrect == -1,:),1);
    % put data together
    pupData = [pupData; pupilBinned];
    predictorsAll = [predictorsAll ;predictors1];
    
end

% bootstrap pupil
meanPupAll = mean(bootstrp(1000,@mean,oneMouseMeanPup),1);
errBPupAll = bootci(1000,@mean,oneMouseMeanPup);

% bootstrap pupil
meanPupAllCorr = mean(bootstrp(1000,@mean,oneMouseMeanPupCorr),1);
errBPupAllCorr = bootci(1000,@mean,oneMouseMeanPupCorr);

% bootstrap pupil
meanPupAllInc = mean(bootstrp(1000,@mean,oneMouseMeanPupInc),1);
errBPupAllInc = bootci(1000,@mean,oneMouseMeanPupInc);

% bootstrap pupil
meanLickAll = mean(bootstrp(1000,@mean,oneMouseMeanLick),1);
errBLickAll = bootci(1000,@mean,oneMouseMeanLick);

% bootstrap pupil
meanLickAllCorr = mean(bootstrp(1000,@mean,oneMouseMeanLickCorr),1);
errBLickAllCorr = bootci(1000,@mean,oneMouseMeanLickCorr);

% bootstrap pupil
meanLickAllInc = mean(bootstrp(1000,@mean,oneMouseMeanLickInc),1);
errBLickAllInc = bootci(1000,@mean,oneMouseMeanLickInc);

%% Plot Betas and Pvals for all animals
% close all
weightsForPlot = weights;

% for i = 1:length(animals)
%     
% %         weights = pupData(i).weightsCorr;
%     
%     figure(i)
%     plot(-0.7+(1:length(weightsForPlot(2:end,:,i)))/10,weightsForPlot(2:end,:,i))
%     hold on
%     xline(0,'k')
%     xlim([-0.75 3])
%     legend(predNames{2:end})
%     %     title('Beta vals')
%     
%     sgtitle(num2str(animals(i)))
% end

% mean of the betas
figure(iiii)
plot(-0.7+(1:length(weightsForPlot(:,:,1)))/10,mean(weightsForPlot(2:end,:,:),3)')
hold on
xline(0,'k')
xlim([-0.75 3])
legend(predNames{2:end})
title('Mean Beta vals')

%% Bootstrapping ALL TRIALS
% close all
weightsForPlot = weights;

m= [];ci =[];
% need to extract one beta weight over time for each animal
for i = 1:size(weightsForPlot,1)
    
    weightsBoot = squeeze(weightsForPlot(i,:,:))';
    
    m(i,:) = mean(bootstrp(1000,@mean,weightsBoot),1);
    ci(:,:,i) = bootci(1000,@mean,weightsBoot);
    
    errBarr = ci(:,:,i);
    betaMean = m(i,:);
%     
    % plot it
    figure(100+iiii)
    subplot(2,4,i)
    shadedErrorBar(-0.7+(1:length(betaMean))/10,betaMean,[errBarr(1,:) - betaMean ; betaMean - errBarr(2,:)],...
        'patchSaturation',0.3)
    hold on
    xline(0,'k')
    xlim([-0.7 3])
    yline(0,'k')
    ylim([-0.1 0.2])
    title(predNames(i))
    
%     if rewardAlign == 1
%         sgtitle([file(1:end-31),' reward Aligned'])
%     else
%         sgtitle([file(1:end-31),' stim onset aligned'])
%     end
end
bootMeanAll = m;
bootErrAll = ci;
% 
% % Bootstrapping CORRECT ONLY
% weightsForPlot = weightsCorr;
% 
% m= [];ci =[];
% % need to extract one beta weight over time for each animal
% for i = 1:size(weightsForPlot,1)
%     
%     weightsBoot = squeeze(weightsForPlot(i,:,:))';
%     
%     m(i,:) = mean(bootstrp(1000,@mean,weightsBoot),1);
%     ci(:,:,i) = bootci(1000,@mean,weightsBoot);
%     
%     errBarr = ci(:,:,i);
%     betaMean = m(i,:);
%     
%     % plot it
%     figure(2)
%     subplot(2,4,i)
%     shadedErrorBar(-0.7+(1:length(betaMean))/10,betaMean,[errBarr(1,:) - betaMean ; betaMean - errBarr(2,:)],...
%         'lineprops', '-g','patchSaturation',0.3)
%     hold on
%     xline(0,'k')
%     xlim([-0.7 3])
%     yline(0,'k')
%     ylim([-0.1 0.2])
%     title(predNamesCorr(i))
% %     
% %     if rewardAlign == 1
% %         sgtitle([file(1:end-31),' reward Aligned'])
% %     else
% %         sgtitle([file(1:end-31),' stim onset aligned'])
% %     end
% end
% bootMeanCorr = m;
% bootErrCorr = ci;
% 
% % Bootstrapping INCORRECT ONLY
% weightsForPlot = weightsInc;
% 
% m= [];ci =[];
% % need to extract one beta weight over time for each animal
% for i = 1:size(weightsForPlot,1)
%     
%     weightsBoot = squeeze(weightsForPlot(i,:,:))';
%     
%     m(i,:) = mean(bootstrp(1000,@mean,weightsBoot),1);
%     ci(:,:,i) = bootci(1000,@mean,weightsBoot);
%     
%     errBarr = ci(:,:,i);
%     betaMean = m(i,:);
%     
%     % plot it
%     figure(2)
%     subplot(2,4,i)
%     shadedErrorBar(-0.7+(1:length(betaMean))/10,betaMean,[errBarr(1,:) - betaMean ; betaMean - errBarr(2,:)],...
%         'lineprops', '-r','patchSaturation',0.3)
%     hold on
%     xline(0,'k')
%     xlim([-0.7 3])
%     yline(0,'k')
%     ylim([-0.1 0.2])
%     title(predNamesCorr(i))
% %     
% %     if rewardAlign == 1
% %         sgtitle([file(1:end-31),' reward Aligned'])
% %     else
% %         sgtitle([file(1:end-31),' stim onset aligned'])
% %     end
% end
% bootMeanInc = m;
% bootErrInc = ci;
% % 
% % if rewardAlign == 1
% %     saveR([file(1:end-14), 'regresResultsRewAlign.RData'],'weightsInc','animals','predNames','predNamesCorr','weightsCorr','weights'...
% %         ,'bootMeanInc','bootErrInc','bootMeanCorr','bootErrCorr','bootMeanAll','bootErrAll','pupData','predictorsAll'...
% %         ,'meanPupAll','errBPupAll','meanPupAllCorr','errBPupAllCorr','meanPupAllInc','errBPupAllInc'...
% %         ,'meanLickAll','errBLickAll','meanLickAllCorr','errBLickAllCorr','meanLickAllInc','errBLickAllInc')
% % else
% %     saveR([file(1:end-14), 'regresResultsStimAlign.RData'],'weightsInc','animals','predNames','predNamesCorr','weightsCorr','weights'...
% %         ,'bootMeanInc','bootErrInc','bootMeanCorr','bootErrCorr','bootMeanAll','bootErrAll','pupData','predictorsAll'...
% %         ,'meanPupAll','errBPupAll','meanPupAllCorr','errBPupAllCorr','meanPupAllInc','errBPupAllInc'...
% %         ,'meanLickAll','errBLickAll','meanLickAllCorr','errBLickAllCorr','meanLickAllInc','errBLickAllInc')
% % end
end