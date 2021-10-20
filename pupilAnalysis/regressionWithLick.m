%% Code for linear regression of pupil data
clear all; close all

%% load correct datatrials mat file
[file,folder] = uigetfile;
fic = fullfile(folder,file);
load(fic)

%% Parameters
animals = [123,155,160,192,222];
nDays = length(dayExpTrials);
fs = 60;

% regression parameters
binSize = 0.2*fs;
moveBy = 0.1*fs;

base = 0.75*fs;

%% Loop through animals and arrange trials and pupil data
mouseExpTrials = []; mousePupilTrials = [];
for i = 1:nDays
    
    % get exp data
    expDat = dayExpTrials(i).expData;
    
    % get pupil 
    pupilDat = dayExpTrials(i).dlcData.pupilSize;
    
    % filter out the repeated trials
%     removeInd = find(expDat(:,10) == 1);
%     expDat(removeInd,:) = [];
%     pupilDat(removeInd,:) = [];
    
    % filter out the >3 sec rt trials
    removeInd = find(expDat(:,11) > 3);
    expDat(removeInd,:) = [];
    pupilDat(removeInd,:) = [];
    
    % add all the trials from one mouse together
    mousePupilTrials = [mousePupilTrials; pupilDat];
    mouseExpTrials = [mouseExpTrials; expDat];
    
end

%% Loop through animals and run regressions
predNames = {'B0','Trial Diff','Sum Contrast','RT','CorrectAngle','Correct'}
% predNames = {'B0','Trial Diff','Sum Contrast','CorrectAngle','Correct'}
% predNames = {'B0','Trial Diff','Sum Contrast','RT','CorrectAngle'}

for i = 1:length(animals)
    
    oneMouseExp = mouseExpTrials(mouseExpTrials(:,13) == animals(i),:);
    oneMousePup = (mousePupilTrials(mouseExpTrials(:,13) == animals(i),:));
    
    % extract parameters for predictive
    allTrialDiff = zscore(oneMouseExp(:,12));
    allContrast = zscore(sum(oneMouseExp(:,7:8),2));
%     oneMouseExp(:,2) = 
    allCorrect = oneMouseExp(:,2);
    allRT = zscore(oneMouseExp(:,11));
    allCorrAng = zscore(min(abs(oneMouseExp(:,5:6)),[],2));

    % prepare predictive variables
    predictors = [ones(length(allTrialDiff),1), allTrialDiff, allContrast, allRT, allCorrAng, allCorrect];
%     predictors = [ones(length(allTrialDiff),1), allTrialDiff, allContrast, allCorrAng, allCorrect];
%     predictors = [ones(length(allTrialDiff),1), allTrialDiff, allContrast, allRT, allCorrAng];

    % loop over the bins
    k = 0;pupilBinned = [];
    for j = 1+binSize/2:moveBy:size(oneMousePup,2)-binSize/2
        k = k+1;
        pupilBinned(:,k) = mean(oneMousePup(:,j-binSize/2:j+binSize/2),2);
        
        [b,bint,r,rint,stats] = regress(pupilBinned(:,k),predictors);
        
        Rvals(i,k) = stats(1);
        pVals(i,k) = stats(3);
        weights(:,k,i) = b;
        
    end
    
    pupData(i).pupilBinned = pupilBinned;
    pupData(i).predictors = predictors;
    pupData(i).Rvals = Rvals(i,:);
    pupData(i).pVals = pVals(i,:);
    pupData(i).weights = weights(:,:,i);
end

save([file(1:end-14), 'regresResults'],'pupData','animals','predNames')
%% Plot Betas and Pvals for all animals
close all
for i = 1:length(animals)
    
    figure(i)
%     subplot(2,1,1)
    plot(-0.7+(1:length(weights(2:end,:,i)))/10,weights(2:end,:,i))
    hold on
    xline(0,'k')
    xlim([-0.75 3])
    legend(predNames{2:end})
%     title('Beta vals')
    
%     subplot(2,1,2)
%     plot(-0.7+(1:length(pVals(i,:)))/10,pVals(i,:))
%     hold on
%     xline(0,'k')
%     xlim([-0.75 3])
%     ylim([0 0.1])
%     title('P=values')
    
    sgtitle(num2str(animals(i)))
end
    
%% Plot mean Beta values 
figure
plot(-0.7+(1:length(weights(:,:,i)))/10,mean(weights(2:end,:,:),3)')
hold on
xline(0,'k')
xlim([-0.75 3])
legend(predNames{2:end})
title('Mean Beta vals')
 
%%


 
%%










