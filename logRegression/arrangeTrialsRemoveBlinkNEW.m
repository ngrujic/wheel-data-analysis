%% Arrange pupil position and size by day
clear all;


condition = '';
cd(['C:\worktemp\Wheel\pupilDat\debugging\oldModel',condition]);
load([condition,'_extractedData.mat'])


% parameters
recFs = 60;

baselineFromTo = [-0.5 -0.1]*recFs;

base = 0.75*recFs;
post = 3*recFs;
blinkLikelihoodThresh = 0.8;

% load previously gotten eye data
% load(uigetfile);


align_to_rew =0;
%% Arrange into trials and re-save

%Variables to collect
Correct = [];
CorrectResponse = [];
Response = [];
OrientLeft = [];
ContrastLeft = [];
OrientRight = [];
ContrastRight = [];
RepeatOn = [];
TrialRepeated = [];
ReactionTime = [];
Date = [];
MouseNr = [];
DateSerial = [];
BaselinePupil = [];
Choice1B = [];

mouseTemp = [];
i = 0;
totalLossOfBlinkTrials=0;
% loop over days
for dayInd = 1:length(dayExp)
    
    dateTempSer = datenum(dayExp(dayInd).date,'dd-mmm-yyyy');
    dayExp(dayInd).expData(1,:) = [];
    dayExp(dayInd).expData(end,:) = [];
    dayExp(dayInd).dlcData(1,:) = [];
    dayExp(dayInd).dlcData(end,:) = [];
    
    mouseTemp =  dayExp(dayInd).expData(1,13);
    
    % get current day DLC data
    dayDLC = dayExp(dayInd).dlcData;
    expDat = dayExp(dayInd).expData;
    %     dayAll = dayExp(dayInd).allEyes;
    %%%%%%%% Z SCORING IS HERE %%%%%%%%%%%
    % Z-score each day pupil size
    dayDLC(:,3) = zscore(dayDLC(:,3));
    
    if ~align_to_rew
        onsets = expDat(:,1);
    else
        onsets = expDat(:,1)+30+expDat(:,4)*60;
    end
    % loop over onsets to extract each trial
    allPupSizes = []; goodTrialInd = 0; blinkTrials = [];dlcData = [];pupilSize = []; xPos = []; yPos = []; lick = []; BaselinePupilTemp=[];pupilSizeConcat=[];
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
            BaselinePupilTemp(goodTrialInd) = mean(dayDLC(currentOnset + baselineFromTo(1):currentOnset + baselineFromTo(2),3));
            %             allPupSizes(:,:,goodTrialInd) = dayAll(currentOnset - base:currentOnset + post,:);
            %             pupilSizeConcat = [pupilSizeConcat pupilSize(goodTrialInd,:)];
        else
            blinkTrials = [blinkTrials onInd];
        end
    end
    dlcData.pupilSize = pupilSize;
    dlcData.xPos = xPos;
    dlcData.yPos = yPos;
    dlcData.lick = lick;
    dlcData.BaselinePupil = BaselinePupilTemp;
    %     close all
    figure(2)
    subplot(2,1,1)
    imagesc(pupilSize);hold on; xline(0.75*60,'r')
    subplot(2,1,2)
    hold off
    
    plot(mean(pupilSize));hold on; xline(0.75*60,'r');xlim([0,226])
    
    keyboard
    %     subplot(4,1,3)
    %     imagesc(lick);hold on; xline(0.75*60,'r')
    %       subplot(4,1,4)
    %     plot(mean(lick,1));hold on; xline(0.75*60,'r');xlim([0,226])
    %%%%%% more debugging bullshit
    meanpup = squeeze(mean(allPupSizes,3));
    
    % add choice of trial before to the expDat
    expDat(:,14) = sign(rand-0.5);
    expDat(2:end,14) = expDat(1:end-1,4);
    
    % remove blink trials also from expDat
    expDat(blinkTrials,:) = [];
    
    DateSerialN = repmat(dateTempSer,size(expDat,1),1);
    
    dayExp(dayInd).dlcData = [];
    dayExp(dayInd).expData = expDat;
    dayExp(dayInd).dlcData = dlcData;
    dayExp(dayInd).datainfo = 'expData columns: onsetFrame, correct, angleDifference, RT, contrast and rew size';
    
    Correct = [Correct; expDat(:,2)];
    CorrectResponse = [CorrectResponse; expDat(:,3)];
    Response = [Response; expDat(:,4)];
    OrientLeft = [OrientLeft; expDat(:,5)];
    ContrastLeft = [ContrastLeft; expDat(:,6)];
    OrientRight = [OrientRight; expDat(:,7)];
    ContrastRight = [ContrastRight; expDat(:,8)];
    RepeatOn = [RepeatOn; expDat(:,9)];
    TrialRepeated = [TrialRepeated;expDat(:,10)];
    ReactionTime = [ReactionTime; expDat(:,11)];
    Choice1B = [Choice1B; expDat(:,14)];
    
    Date = [Date; repmat(i,size(expDat,1),1)];
    MouseNr = [MouseNr; expDat(:,13)];
    
    DateSerial = [DateSerial; DateSerialN];
    BaselinePupil = [BaselinePupil; dlcData.BaselinePupil'];
    
    totalLossOfBlinkTrials = totalLossOfBlinkTrials + length(blinkTrials);
    
end

%% save and make table
AllMouseData = table(Correct, CorrectResponse, Response, Choice1B, OrientLeft,...
    OrientRight, ContrastLeft, ContrastRight, RepeatOn, TrialRepeated, ReactionTime,...
    Date, MouseNr, BaselinePupil, DateSerial);
i3

totalLossOfBlinkTrials

if align_to_rew
    save([condition, '_dataTrialsReward.mat'],'dayExp','base','post','blinkLikelihoodThresh')
else
    save([condition, '_dataTrials.mat'],'dayExp','base','post','blinkLikelihoodThresh')
end