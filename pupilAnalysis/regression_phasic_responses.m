%% Code for linear regression of pupil data
clear all; close all

%% load correct datatrials mat file
direc{2} = "C:\worktemp\Wheel\pupilDat\wrongRewardTask\wrongRewardTask_outliersRemoved_dataTrials.mat"
direc{1} = "C:\worktemp\Wheel\pupilDat\accuracyTask\accuracyTask_outliersRemoved_dataTrials.mat"
direc{3} = "C:\worktemp\Wheel\pupilDat\correctRewardTask\correctRewardTask_outliersRemoved_dataTrials.mat"

weightsMaxResp = []
for iiii = 1:3
    %% LOOP REWARD
    clearvars -except saveIncLickHeatmap allConditionsMaxRespI saveCorrLickHeatmap saveIncPupHeatmap saveCorrPupHeatmap fic rewardAlign file folder iiii direc allConditionsMaxRespC allConditionsLickC allConditionsLickI weightsMaxResp
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
        
        % add all the trials from one mouse together
        mousePupilTrials = [mousePupilTrials; pupilDat];
        mouseExpTrials = [mouseExpTrials; expDat];
        mouseLickTrials = [ mouseLickTrials; lickDat];
    end
    
    %% Loop through animals and run regressions
 
    pupData = [];allMiceCorrAng= []; allMiceDTheta = [];lickData=[];allMouseN =[] ;maxPupResps = [];allMiceCorrect=[];
    for i = 1:length(animals)
        maxLickResp = [];maxPupResp = [];
        oneMouseExp = mouseExpTrials(mouseExpTrials(:,13) == animals(i),:);
        oneMousePup = mousePupilTrials(mouseExpTrials(:,13) == animals(i),:);
        oneMouseLick = mouseLickTrials(mouseExpTrials(:,13) == animals(i),:);
        
        % extract parameters for predictive
        allTrialDiff = zscore(oneMouseExp(:,12));
        allTrialDiffNoZ = oneMouseExp(:,12);
        
        allContrast = zscore(sum(oneMouseExp(:,7:8),2));
        allChoice1B = oneMouseExp(:,15); allChoice1B(allChoice1B == 0) = -1;
        allCorrect = oneMouseExp(:,2); allCorrect(allCorrect == 0) = -1;
        allRT = zscore(oneMouseExp(:,11));
        
        meanRTmouse(i) = mean(oneMouseExp(:,11));
        
        allCorrAng = zscore(min(abs(oneMouseExp(:,5:6)),[],2));
        allCorrAngNoZ = min(abs(oneMouseExp(:,5:6)),[],2);
        
        allDisengaged = oneMouseExp(:,16); allDisengaged(allDisengaged == 0) = -1;
        mouse = mouseExpTrials(mouseExpTrials(:,13) == animals(i),13);
        
        % SUBTRACTING BASELINE 
        for j = 1:size(oneMousePup,1)
            oneMousePup(j,1:end) = (oneMousePup(j,:) - mean(oneMousePup(j,1:7)));
        end  
        
        % Arranging by reward
        if rewardAlign == 1
            oneMousePupRew = [];
            for j = 1:size(oneMousePup,1)
                oneMousePupRew(j,:) = oneMousePup(j,round((oneMouseExp(j,11)*60))+30:round((oneMouseExp(j,11)*60))+30 +base +180);
                oneMouseLickRew(j,:) = oneMouseLick(j,round((oneMouseExp(j,11)*60))+30:round((oneMouseExp(j,11)*60))+30 +base +180); 
            end
            oneMousePup = oneMousePupRew;
            oneMouseLick = oneMouseLickRew;
        end
        
        % BINNING PUPIL AND LICK
        k = 0;pupilBinned = [];lickBinned = [];pupDat= [];
        for j = 1+binSize/2:moveBy:size(oneMousePup,2)-binSize/2
            k = k+1;
            pupilBinned(:,k) = mean(oneMousePup(:,j-binSize/2:j+binSize/2),2);
            lickBinned(:,k) = mean(oneMouseLick(:,j-binSize/2:j+binSize/2),2);
        end
        
        % SUBTRACTING BASELINE 
%         for j = 1:size(pupilBinned,1)
%             pupilBinned(j,:) = pupilBinned(j,:) - mean(pupilBinned(j,1:6));
%         end    
        
%         if rewardAlign == 1
%             for j = 1:size(pupilBinned,1)
%                 pupilRew(j,:) = pupilBinned(5+oneMouseExp(j,11)*10
%             end
%         end
        
        % MEANS PUPIL
        oneMouseMeanPup(i,:) = mean(pupilBinned,1);
        oneMouseMeanLick(i,:) = mean(lickBinned,1);
        
        % MEANS  correct
        oneMouseMeanPupCorr(i,:) = mean(pupilBinned(allCorrect == 1 & allDisengaged == -1,:),1);
        oneMouseMeanLickCorr(i,:) = mean(lickBinned(allCorrect == 1 & allDisengaged == -1,:),1);
        
        % MEANS incorrect
        oneMouseMeanPupInc(i,:) = mean(pupilBinned(allCorrect == -1 & allDisengaged == -1,:),1);
        oneMouseMeanLickInc(i,:) = mean(lickBinned(allCorrect == -1 & allDisengaged == -1,:),1);
       
        % put data from different mice together
        pupData = [pupData; pupilBinned(allDisengaged == -1,:)];
        lickData = [lickData; lickBinned(allDisengaged == -1,:)];
        allMiceCorrAng = [allMiceCorrAng; allCorrAngNoZ(allDisengaged == -1,:)];
        allMiceDTheta = [allMiceDTheta; allTrialDiffNoZ(allDisengaged == -1,:)];
        allMouseN = [allMouseN; mouse(allDisengaged == -1,:)];
        allMiceCorrect = [allMiceCorrect; allCorrect];
    end
    
    %% PLOT by reward size ( correct angle ) only for most difficult or all trials correct and incorrect separately
%     
    wantonlyangle = 20
    wantonlyangle2 = 30
% 
%     % filter out trial difficuylty
        allMouseNp = allMouseN(allMiceDTheta == wantonlyangle | allMiceDTheta == wantonlyangle2);
        corrAngPlot = allMiceCorrAng(allMiceDTheta == wantonlyangle | allMiceDTheta == wantonlyangle2);
        pupPlot = pupData(allMiceDTheta == wantonlyangle | allMiceDTheta == wantonlyangle2,:);
        lickPlot = lickData(allMiceDTheta == wantonlyangle | allMiceDTheta == wantonlyangle2,:);
        correctFilt = allMiceCorrect(allMiceDTheta == wantonlyangle | allMiceDTheta == wantonlyangle2);
%     
%     % filter out correct angles and bin them
    pupPlot(corrAngPlot >30 & corrAngPlot <60,:) = [];
    lickPlot(corrAngPlot >30 & corrAngPlot <60,:) = [];
    correctFilt(corrAngPlot >30 & corrAngPlot <60) = [];
    allMouseNp(corrAngPlot >30 & corrAngPlot <60) = [];

    corrAngPlot(corrAngPlot >30 & corrAngPlot <60) = [];
    corrAngPlot(corrAngPlot<=30) = 0;
    corrAngPlot(corrAngPlot>=60) = 1;
    
    % all trial difficulties
%     allMouseNp = allMouseN;
%     corrAngPlot = allMiceCorrAng;
%     pupPlot = pupData;
%     lickPlot = lickData;
%     correctFilt = allMiceCorrect;
    
    unAng = unique(corrAngPlot);
    unAng = unAng(1:end);
    meanPupThetCorr = []; meanLickThetCorr = []; meanPupThetInc = []; meanLickThetInc = [];
    
    % HOW MANY PEAK BINS TO TAKE
    nMaxBins = 5
    onlyQuiescence = 0
    % loop over animals and correct angles to get averages 
    for aa = 1:length(animals)
        for a = 1:length(unAng)
            
            meanPupThetCorr(a,:,aa) = mean(pupPlot(corrAngPlot == unAng(a) & correctFilt == 1 & allMouseNp == animals(aa),:),1);
            meanLickThetCorr(a,:,aa) = mean(lickPlot(corrAngPlot == unAng(a) & correctFilt == 1 & allMouseNp == animals(aa),:),1);
            
            meanPupThetInc(a,:,aa) = mean(pupPlot(corrAngPlot == unAng(a) & correctFilt == -1 & allMouseNp == animals(aa),:),1);
            meanLickThetInc(a,:,aa) = mean(lickPlot(corrAngPlot == unAng(a) & correctFilt == -1 & allMouseNp == animals(aa),:),1);
            
            if onlyQuiescence == 1
            maxPupRespC(aa,a) = mean(maxk(meanPupThetCorr(a,8:12,aa),nMaxBins));
            else
            maxPupRespC(aa,a) = mean(maxk(meanPupThetCorr(a,:,aa),nMaxBins));
            end
            
            maxLickRespC(aa,a) = mean(maxk(meanLickThetCorr(a,:,aa),nMaxBins));
            
            maxPupRespI(aa,a) = mean(maxk(meanPupThetInc(a,:,aa),nMaxBins));
            maxLickRespI(aa,a) = mean(maxk(meanLickThetInc(a,:,aa),nMaxBins));
        end
%         


%  regression: Correct side angle 0 - 70, DeltaTheta, LastTrialCorrect, Correct 

%             % plot per mouse
%             figure(aa+iiii*10)
%             sgtitle(num2str(animals(aa)))
%             subplot(2,2,1)
%             imagesc(meanPupThetCorr(:,:,aa))
%             xticks(0.7*106/10:106/10:106)
%             xticklabels(0:1:10)
%             xlim([1, 40])
%             xline(0.7*106/10,'r')
%             title('pupil correct')
%             yticks(1:length(unAng))
%             yticklabels(unAng)
%             caxis([-0.3 0.7])
%         
%             subplot(2,2,2)
%             imagesc(meanLickThetCorr(:,:,aa))
%             xticks(0.7*106/10:106/10:106)
%             xticklabels(0:1:10)
%             xlim([1, 40])
%             xline(0.7*106/10,'r')
%             title('licking correct')
%             yticks(1:length(unAng))
%             yticklabels(unAng)
%             caxis([0 0.3])
%         
%             subplot(2,2,3)
%             imagesc(meanPupThetInc(:,:,aa))
%             xticks(0.7*106/10:106/10:106)
%             xticklabels(0:1:10)
%             xlim([1, 40])
%             xline(0.7*106/10,'r')
%             title('pupil incorrect')
%             yticks(1:length(unAng))
%             yticklabels(unAng)
%             caxis([-0.3 0.7])
%         
%             subplot(2,2,4)
%             imagesc(meanLickThetInc(:,:,aa))
%             xticks(0.7*106/10:106/10:106)
%             xticklabels(0:1:10)
%             xlim([1, 40])
%             xline(0.7*106/10,'r')
%             title('licking incorrect')
%             yticks(1:length(unAng))
%             yticklabels(unAng)
%             caxis([0 0.3])
    end
    
    
    % maximal responses
    figure(iiii)
    sgtitle('maximal responses')
    subplot(2,1,1)
    plot(mean(maxPupRespC,1),'g')
    hold on
    plot(mean(maxPupRespI,1),'r')
    xticklabels(unAng)
    % ylim([0 1])
    title('pupil')
    
    allConditionsMaxRespC(:,:,iiii) = maxPupRespC;
    allConditionsMaxRespI(:,:,iiii) = maxPupRespI;
    
    allConditionsLickC(:,:,iiii) = maxLickRespC;
    allConditionsLickI(:,:,iiii) = maxLickRespI;
    
    subplot(2,1,2)
    plot(mean(maxLickRespC,1),'g')
    hold on
    plot(mean(maxLickRespI,1),'r')
    xticklabels(unAng)
    % ylim([0 1])
    title('lick')
    
    
    
    % max responses corr - inc
%     figure(80+iiii)
%     plot(mean(maxPupRespC - maxPupRespI,1))
%     xticklabels(unAng)
%     title('pupil max corr - max inc responses')

    % responses over time for all angles
    figure(90+iiii)
    sgtitle('Mean of all Mice')
    subplot(2,2,1)
    imagesc(mean(meanPupThetCorr,3))
    xticks(0.7*106/10:106/10:106)
    xticklabels(0:1:10)
    xlim([1, 40])
    xline(0.7*106/10,'r')
    title('pupil correct')
    yticks(1:length(unAng))
    yticklabels(unAng)
    caxis([-0.3 0.3])
    
    subplot(2,2,2)
    imagesc(mean(meanLickThetCorr,3))
    xticks(0.7*106/10:106/10:106)
    xticklabels(0:1:10)
    xlim([1, 40])
    xline(0.7*106/10,'r')
    title('licking correct')
    yticks(1:length(unAng))
    yticklabels(unAng)
    caxis([0 0.3])
    
    subplot(2,2,3)
    imagesc(mean(meanPupThetInc,3))
    xticks(0.7*106/10:106/10:106)
    xticklabels(0:1:10)
    xlim([1, 40])
    xline(0.7*106/10,'r')
    title('pupil incorrect')
    yticks(1:length(unAng))
    yticklabels(unAng)
    caxis([-0.3 0.3])
    
    subplot(2,2,4)
    imagesc(mean(meanLickThetInc,3))
    xticks(0.7*106/10:106/10:106)
    xticklabels(0:1:10)
    xlim([1, 40])
    xline(0.7*106/10,'r')
    title('licking incorrect')
    yticks(1:length(unAng))
    yticklabels(unAng)
    caxis([0 0.3])
  
    saveCorrPupHeatmap(:,:,iiii) = mean(meanPupThetCorr,3);
    saveIncPupHeatmap(:,:,iiii) = mean(meanPupThetInc,3);
    saveCorrLickHeatmap(:,:,iiii) = mean(meanLickThetCorr,3);
    saveIncLickHeatmap(:,:,iiii) = mean(meanLickThetInc,3);

end 
%%
%%%%% CHECK JUST AVERAGES OF BINNED
lowHighPriorDiffs = allConditionsMaxRespC(:,1,:) -  allConditionsMaxRespC(:,2,:);
meanDiffsConds =(mean(lowHighPriorDiffs,1));
meanConds = mean(allConditionsMaxRespC,1);

figure(9000);plot(squeeze(meanConds));legend({'accuracy task','wrong task','correct task'})
xticks([1 2]); xticklabels(["low prior","high prior"])


% plot(mean(allConditionsMaxRespC(:,:,1),1))
% hold on
% plot(mean(allConditionsMaxRespC(:,:,2),1),'r')
% hold on;
figure
subplot(2,1,1)
plot([mean(allConditionsMaxRespC(:,:,2),1);mean(allConditionsMaxRespC(:,:,3));mean(allConditionsMaxRespC(:,:,1))]')
legend({'wrong task','correct rew task','accuracyTask'})
xticklabels(unAng)
ylabel('Peak of phasic pupil response')
xlabel('Correct side angle')

subplot(2,1,2)
plot([mean(allConditionsLickC(:,:,2),1);mean(allConditionsLickC(:,:,3));mean(allConditionsLickC(:,:,1))]')
legend({'wrong task','correct rew task','accuracyTask'})
xticklabels(unAng)
ylabel('Peak of lick response')
xlabel('Correct side angle')

%%

x = zscore(1:length(unAng))
for a = 1:5
    c1(a,:) = polyfit(x,mean(allConditionsMaxRespC(a,:,1),1),1)
    c2(a,:) = polyfit(x,mean(allConditionsMaxRespC(a,:,2),1),1)
    c3(a,:) = polyfit(x,mean(allConditionsMaxRespC(a,:,3),1),1)
    
end
% for a = 1:5
%     c1(a,:) = polyfit(x,mean(allConditionsMaxRespI(a,:,1),1),1)
%     c2(a,:) = polyfit(x,mean(allConditionsMaxRespI(a,:,2),1),1)
%     c3(a,:) = polyfit(x,mean(allConditionsMaxRespI(a,:,3),1),1)
%     
% end

cMeans = [mean(c1(:,1),1) mean(c2(:,1),1) mean(c3(:,1),1)]


% pairwise comparisons
% acc_wro = (c1(:,1) - c2(:,1))
% acc_cor = (c1(:,1) - c3(:,1))
% wro_cor = (c2(:,1) - c3(:,1))
% or just means
acc_wro = c1(:,1) 
acc_cor = c2(:,1)
wro_cor = c3(:,1)

bootacc_wro = mean(bootstrp(10000,@mean,acc_wro,1));
errBacc_wro = bootci(10000,@mean,acc_wro)
bootacc_cor = mean(bootstrp(10000,@mean,acc_cor,1));
errBacc_cor = bootci(10000,@mean,acc_cor)
bootwro_cor = mean(bootstrp(10000,@mean,wro_cor,1));
errBwro_cor = bootci(10000,@mean,wro_cor)

forScat = [acc_wro' acc_cor' wro_cor']
forline = [acc_wro acc_cor wro_cor]
forbar = [mean(acc_wro) mean(acc_cor) mean(wro_cor)];
x = [ones(1,5) ones(1,5)*2 ones(1,5)*3]
symbs = [1:5 1:5 1:5]

figure(200)
xticks(1:3); xlim([0 4]);
% xticklabels({'acc - wro','acc - corr','wro - corr'})
xticklabels({'acc','wro','corr'})

hold on
b = bar(1:3,forbar, 'k');
b.FaceColor = 'flat';
b.FaceColor = [0.5 0.5 0.5];
hold on
errorbar(1:3,forbar,forbar-[errBacc_wro(1) errBacc_cor(1) errBwro_cor(1)],forbar-[errBacc_wro(2) errBacc_cor(2) errBwro_cor(2)],'k','LineWidth',2)
hold on
plot(1:3,forline,'k')
hold on
gscatter(x,forScat,symbs)

ylabel('Delta slope parameter of max pup resp')

% saveR('pupilCorr.RData','c1','c2','c3','saveCorrPupHeatmap','saveIncPupHeatmap','saveCorrLickHeatmap','saveIncLickHeatmap') 


%

% hold on
% plot(mean(allConditionsMaxRespC(a,:,2),1),'r')
% hold on;
% plot(mean(allConditionsMaxRespC(a,:,3),1),'m')


% %% Plot Betas and Pvals for all animals
% %     close all
% weightsForPlot = weights;
%
% for i = 1:length(animals)
%
%     %     weights = pupData(i).weightsCorr;
%     %
%     %     figure(i)
%     %     plot(-0.7+(1:length(weightsForPlot(2:end,:,i)))/10,weightsForPlot(2:end,:,i))
%     %     hold on
%     %     xline(0,'k')
%     %     xlim([-0.75 3])
%     %     legend(predNames{2:end})
%     %     %     title('Beta vals')
%     %
%     %     sgtitle(num2str(animals(i)))
% end
%
% % mean of the betas
% figure
% plot(-0.7+(1:length(weightsForPlot(:,:,1)))/10,mean(weightsForPlot(2:end,:,:),3)')
% hold on
% xline(0,'k')
% xlim([-0.75 3])
% legend(predNames{2:end})
% title('Mean Beta vals')
%
% %% Bootstrapping ALL TRIALS
% close all
% weightsForPlot = weights;
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
%     %
%     %     % plot it
%     %     figure(1)
%     %     subplot(2,4,i)
%     %     shadedErrorBar(-0.7+(1:length(betaMean))/10,betaMean,[errBarr(1,:) - betaMean ; betaMean - errBarr(2,:)],...
%     %         'patchSaturation',0.3)
%     %     hold on
%     %     xline(0,'k')
%     %     xlim([-0.7 3])
%     %     yline(0,'k')
%     %     ylim([-0.1 0.2])
%     %     title(predNames(i))
%     %
%     %     if rewardAlign == 1
%     %         sgtitle([file(1:end-31),' reward Aligned'])
%     %     else
%     %         sgtitle([file(1:end-31),' stim onset aligned'])
%     %     end
% end
% bootMeanAll = m;
% bootErrAll = ci;
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
%     %         ylim([-0.1 0.2])
%     title(predNamesCorr(i))
%     %
%     %     if rewardAlign == 1
%     %         sgtitle([file(1:end-31),' reward Aligned'])
%     %     else
%     %         sgtitle([file(1:end-31),' stim onset aligned'])
%     %     end
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
%     %         ylim([-0.1 0.2])
%     title(predNamesCorr(i))
%     %
%     %     if rewardAlign == 1
%     %         sgtitle([file(1:end-31),' reward Aligned'])
%     %     else
%     %         sgtitle([file(1:end-31),' stim onset aligned'])
%     %     end
% end
% bootMeanInc = m;
% bootErrInc = ci;

% Bootstrapping DISENGAGED ONLY
%     weightsForPlot = weightsDis;
%
%     m= [];ci =[];
%     % need to extract one beta weight over time for each animal
%     for i = 1:size(weightsForPlot,1)
%
%         weightsBoot = squeeze(weightsForPlot(i,:,:))';
%
%         m(i,:) = mean(bootstrp(1000,@mean,weightsBoot),1);
%         ci(:,:,i) = bootci(1000,@mean,weightsBoot);
%
%         errBarr = ci(:,:,i);
%         betaMean = m(i,:);
%
%         % plot it
%         figure(2)
%         subplot(2,4,i)
%         shadedErrorBar(-0.7+(1:length(betaMean))/10,betaMean,[errBarr(1,:) - betaMean ; betaMean - errBarr(2,:)],...
%             'lineprops', '-k','patchSaturation',0.3)
%         hold on
%         xline(0,'k')
%         xlim([-0.7 3])
%         yline(0,'k')
% %         ylim([-0.1 0.2])
%         title(predNamesCorr(i))
%         %
%         %     if rewardAlign == 1
%         %         sgtitle([file(1:end-31),' reward Aligned'])
%         %     else
%         %         sgtitle([file(1:end-31),' stim onset aligned'])
%         %     end
%     end
%     bootMeanInc = m;
%     bootErrInc = ci;
% if rewardAlign == 1
%     saveR([file(1:end-14), 'regresResultsRewAlign.RData'],'weightsInc','animals','predNames','predNamesCorr','weightsCorr','weights'...
%         ,'bootMeanInc','bootErrInc','bootMeanCorr','bootErrCorr','bootMeanAll','bootErrAll','pupData','predictorsAll'...
%         ,'meanPupAll','errBPupAll','meanPupAllCorr','errBPupAllCorr','meanPupAllInc','errBPupAllInc'...
%         ,'meanLickAll','errBLickAll','meanLickAllCorr','errBLickAllCorr','meanLickAllInc','errBLickAllInc')
% else
%     saveR([file(1:end-14), 'regresResultsStimAlign.RData'],'weightsInc','animals','predNames','predNamesCorr','weightsCorr','weights'...
%         ,'bootMeanInc','bootErrInc','bootMeanCorr','bootErrCorr','bootMeanAll','bootErrAll','pupData','predictorsAll'...
%         ,'meanPupAll','errBPupAll','meanPupAllCorr','errBPupAllCorr','meanPupAllInc','errBPupAllInc'...
%         ,'meanLickAll','errBLickAll','meanLickAllCorr','errBLickAllCorr','meanLickAllInc','errBLickAllInc')
% end
