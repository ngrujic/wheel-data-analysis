%% loadData
clear all
load trialDLCdat_07202020
load wheel_M222_20-Jul-2020_151547 RT contrastR contrastL correct orientationL orientationR rewardMs

%% put variables together in one matrix
dlcDat = cat(3,pupSizeTrials, licksTrials, eyeCentreTrialsX, eyeCentreTrialsY, stimOnTrials,licksReward,pupSizeReward);
varOrder = {'pupil Size','licks', 'eye pos X', 'eye pos Y', 'stim On','licks Reward aligned','pupil Size Reward aligned'}

dlcDat = dlcDat(~blinkTrial,:,:);
correct = correct(~blinkTrial);
rewardMs = rewardMs(~blinkTrial);

correctDlcDat= dlcDat(correct,:,:);
incorrectDlcDat = dlcDat(~correct,:,:);

%% plot after splitting
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
    xticks([base:60:base+post]); xticklabels([base:60:base+post]/60-1)
    
    % correct imagesc
    tempDat = dlcDat(correct,:,a); % for caxis percentile
    i = i+1;
    figure(2)
    subplot(size(dlcDat,3),2,i)
    imagesc(dlcDat(correct,:,a))
    title(varOrder{a})
    hold on; xline(base,'m','LineWidth',2)
    caxis([prctile(tempDat(:),25) prctile(tempDat(:),75)])
    xticks([base:60:base+post]); xticklabels([base:60:base+post]/60-1)
    
    % incorrect imagesc
    
    i = i+1;
    subplot(size(dlcDat,3),2,i)
    imagesc(dlcDat(~correct,:,a))
    caxis([prctile(tempDat(:),25) prctile(tempDat(:),75)])
    title(varOrder{a})
    hold on; xline(base,'m','LineWidth',2)
    xticks([base:60:base+post]); xticklabels([base:60:base+post]/60-1)
    
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
        plot(mean(tempDat(:,:,aa),1),'Color',[a/length(unRewSiz) 0 a/length(unRewSiz) ]);
        title(varOrder{aa})
        hold on; xline(base,'m','LineWidth',2)
        xticks([base:60:base+post]); xticklabels([base:60:base+post]/60-1)
        
    end
    
end




