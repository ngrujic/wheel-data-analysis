%% Arrange pupil position and size by day
clear all;
% parameters
recFs = 60;
normalizeBy = 0.15;
base = 0.75*recFs;
post = 3*recFs;
blinkLikelihoodThresh = 0.5;

% load previously gotten eye data
load extractedData.mat;


%% Arrange into trials and re-save

% loop over days
for dayInd = 1:length(dayExp)
    
    % get current day DLC data
    dayDLC = dayExp(dayInd).dlcData;
    expDat = dayExp(dayInd).expData;
    
    onsets = expDat(:,1);
    
    % loop over onsets to extract each trial
    goodTrialInd = 0; blinkTrials = [];dlcData = [];pupilSize = []; xPos = []; yPos = []; lick = [];
    for onInd = 1:length(onsets)
        currentOnset = onsets(onInd);
        
        % see if any points are badly, tracked or not present due to blink
        likelihoodTrials = dayDLC(currentOnset - base:currentOnset + post,5:end);
        
        % only fill trials matrix with good trials
        if min(likelihoodTrials(:)) > blinkLikelihoodThresh
            goodTrialInd = goodTrialInd+1;
            pupilSize(goodTrialInd,:) = dayDLC(currentOnset - base:currentOnset + post,3);
            xPos(goodTrialInd,:) = dayDLC(currentOnset - base:currentOnset + post,1);
            yPos(goodTrialInd,:) = dayDLC(currentOnset - base:currentOnset + post,2);
            lick(goodTrialInd,:) = dayDLC(currentOnset - base:currentOnset + post,4);
        else    
            blinkTrials = [blinkTrials onInd];
        end
    end
    dlcData.pupilSize = pupilSize;
    dlcData.xPos = xPos;
    dlcData.yPos = yPos;
    dlcData.lick = lick;
    % remove blink trials also from expDat
    expDat(blinkTrials,:) = [];
    dayExp(dayInd).dlcData = [];
    dayExp(dayInd).expData = expDat;
    dayExp(dayInd).dlcData = dlcData;
    dayExp(dayInd).datainfo = 'expData columns: onsetFrame, correct, angleDifference, RT';
    
end

save('dataTrials.mat','dayExp','base','post','blinkLikelihoodThresh')
