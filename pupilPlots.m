%% loadData
clear all; close all
% select output from the pupilOnsets.m code
load(uigetfile('*.mat'))


%% put variables together in one matrix
dlcDat = cat(3,pupSizeTrials, licksTrials,pupSizeReward,licksReward);
varOrder = {'pupil Size','licks','pupil Size Reward aligned','licks Reward aligned'}

% remove blink trials from dlc data
dlcDat = dlcDat(~blinkTrial,:,:);

%% plot after splitting into correct, incorrect
correctDlcDat= dlcDat(correct,:,:);
incorrectDlcDat = dlcDat(~correct,:,:);

i =0;
for a = 1:size(dlcDat,3)
    
    % Means
    figure(1)
    subplot(size(dlcDat,3),1,a)
    plot(mean(dlcDat(correct,:,a),1),'b')
    hold on
    plot(mean(dlcDat(~correct,:,a),1),'r')
    title(varOrder{a})
    hold on; xline(base,'m','LineWidth',2)
    xticks([base:60:base+post]); xticklabels([0:60:base+post]/60)
    
    % correct imagesc
    tempDat = dlcDat(correct,:,a); % for caxis percentile
    i = i+1;
    figure(2)
    subplot(size(dlcDat,3),2,i)
    imagesc(dlcDat(correct,:,a))
    title(varOrder{a})
    hold on; xline(base,'m','LineWidth',2)
    caxis([prctile(tempDat(:),10) prctile(tempDat(:),90)])
    xticks([base:60:base+post]); xticklabels([0:60:base+post]/60)
    
    % incorrect imagesc
    
    i = i+1;
    subplot(size(dlcDat,3),2,i)
    imagesc(dlcDat(~correct,:,a))
    caxis([prctile(tempDat(:),25) prctile(tempDat(:),75)])
    title(varOrder{a})
    hold on; xline(base,'m','LineWidth',2)
    xticks([base:60:base+post]); xticklabels([0:60:base+post]/60)
    
end
sgtitle('Correct trials L - Incorrect trials R')

%% Split by reward size
unRewSiz = unique(rewardMs);
unRewSiz = unRewSiz(3:end);
for a = 1:length(unRewSiz)
    
    tempDat = dlcDat( rewardMs == unRewSiz(a) & correct,:,:);
    nRewTrials(a) = size(tempDat,1);
    
    % Means
    figure(3)
    for aa = 1:size(tempDat,3)
        
        subplot(size(tempDat,3),1,aa)
        plot(mean(tempDat(:,:,aa),1),'Color',[a/length(unRewSiz) 0 0 ]);
        title(varOrder{aa})
        hold on; xline(base,'m','LineWidth',2)
        xticks([base:60:base+post]); xticklabels([0:60:base+post]/60)
        
    end
    
end
sgtitle('Split by reward size')

%% Split by contrast

totalContrast = contrastR - contrastL;

unRewSiz = unique(totalContrast);
unRewSiz = unRewSiz(1:end);
for a = 1:length(unRewSiz)
    
    tempDat = dlcDat( totalContrast == unRewSiz(a) & correct,:,:);
    nRewTrials(a) = size(tempDat,1);
    
    % Means
    figure(5)
    for aa = 1:size(tempDat,3)
        
        subplot(size(tempDat,3),1,aa)
        plot(mean(tempDat(:,:,aa),1),'Color',[a/length(unRewSiz) 0 0 ]);
        title(varOrder{aa})
        hold on; xline(base,'m','LineWidth',2)
        xticks([base:60:base+post]); xticklabels([0:60:base+post]/60)
        
        
    end
    
end
sgtitle('Split by R - L contrast')





