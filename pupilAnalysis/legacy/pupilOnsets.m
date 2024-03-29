clear all; close all

% parameters
recFs = 60;
normalizeBy = 0.15;
base = 0.5*recFs;
post = 2*recFs;
blinkLikelihoodThresh = 0.88;

% input desired dates to put together in format DDMMYY
dayz = (uigetfile('*.csv','MultiSelect','on'));
if iscell(dayz)
    nRecs = length(dayz);
else
    nRecs =1;
end

M = []; onsets = [];RT = [];contrastR = [];contrastL = [];correct = [];orientationL = [];orientationR = [];rewardMs = [];
recFramesLength = [0];
for a = 1:length(dayz)
    % if one or more
    if iscell(dayz)
        csvfile = cell2mat(dayz(a));
    else
        csvfile =dayz;
    end
    
    trainMatDate = datenum(csvfile(5:12), 'mmddyyyy');
    trainMatText = datestr(trainMatDate,'dd-mmm-yyyy');
    csvDate = csvfile(5:12);
    % load Peters .txt onsets file
    txtFile = dir(['*' csvDate '*txt']);
    thresholdedVals = load(txtFile(3).name);
    
    
    
    
    [xxx,onsetsDat] = getanalogsignalonsets_pupil(thresholdedVals,0.5,60,betweenOnsetsFrame,0,0,0);
    onsets = [onsets load(txtFile.name)+recFramesLength(a) ];
    
    % actually read from correct files
    % read the csv file
    M = [M; csvread(csvfile,3,0)];
    recFramesLength(a+1) = length(M);
    
    % load mat file for the training day output
    matFile = dir(['wheel*' trainMatText '*.mat']);
    testy(a) = load(matFile.name, 'RT', 'contrastR', 'contrastL', 'correct', 'orientationL', 'orientationR', 'rewardMs')
    RT = [RT  testy(a).RT];
    contrastR = [contrastR  testy(a).contrastR];
    contrastL = [contrastL  testy(a).contrastL];
    correct = [correct  testy(a).correct];
    orientationL = [orientationL  testy(a).orientationL];
    orientationR = [orientationR testy(a).orientationR];
    rewardMs = [rewardMs testy(a).rewardMs];
    
    
    betweenOnsetsFrame = RT + ITI(1:length(correct)) + 60;
    
    length(testy(a).correct)
    length(load(txtFile.name))
    % keyboard
end

% convert reaction times to frame time
RTframes = round(RT*recFs);

%% eyes x and y positions and  EYE centre

for eyes = 0:7
    
    eyesX(:,1+eyes) = M(:,2+eyes*3);
    eyesY(:,1+eyes) = M(:,3+eyes*3);
    eyesLikelihood(:,1+eyes) = M(:,4 + eyes*3);
end

% for blink detection eye likelihood
eyesLikelihood = mean(eyesLikelihood,2);

%stim on digital
stimOn = double(M(:,31) >0.5);

% lick digital
licks = double(M(:,28) >0.5);

% eye centre and zscore of the same
eyeCentre(:,1) = mean(eyesX,2);
eyeCentre(:,2) = mean(eyesY,2);

zEyeCentre(:,1) = zscore(mean(eyesX,2));
zEyeCentre(:,2) = zscore(mean(eyesY,2));

%% PUPIL size

for eyes = 1:8
    
    
    % pythagoras for each position with each other position
    
    eyePointDistances(:,eyes) = sqrt((abs(eyeCentre(:,1) - eyesX(:,eyes))).^2 ...
        +(abs(eyeCentre(:,2) - eyesY(:,eyes))).^2);
    
    
end

pupilSize = smooth(zscore(mean(eyePointDistances,2)));

%% arranging everything by onset or by reward

for onId = 1:length(onsets)
    
    % find bad trials
    eyeLikeliTrials(onId,:) = eyesLikelihood(onsets(onId)-base:onsets(onId)+post);
    blinkTrial(onId,:) = min(eyeLikeliTrials(onId,:)) < blinkLikelihoodThresh;
    
    % arrange variables by onset time
    pupSizeTrials(onId,:) = pupilSize(onsets(onId)-base:onsets(onId)+post);%...
    - mean(pupilSize(onsets(onId)-base:onsets(onId)));
    
    licksTrials(onId,:) = licks(onsets(onId)-base:onsets(onId)+post);
    
    eyeCentreTrialsX(onId,:) = zEyeCentre(onsets(onId)-base:onsets(onId)+post,1); %- mean(zEyeCentre(onsets(onId)-normalizeBy:onsets(onId),1));
    eyeCentreTrialsY(onId,:) = zEyeCentre(onsets(onId)-base:onsets(onId)+post,2); %- mean(zEyeCentre(onsets(onId)-normalizeBy:onsets(onId),2));
    
    stimOnTrials(onId,:) = stimOn(onsets(onId)-base:onsets(onId)+post);
    
    % arrange variables by reward time + RT
    licksReward(onId,:) = licks(onsets(onId) +30 +RTframes(onId) -base : onsets(onId) +30 +RTframes(onId) +post);
    pupSizeReward(onId,:) = pupilSize(onsets(onId) +30 +RTframes(onId) -base : onsets(onId) +30 +RTframes(onId) +post);%...
    - mean(pupilSize(onsets(onId)-base:onsets(onId)));
    
end

% removing blink trials for trial variables
correct = logical(correct(~blinkTrial));
rewardMs = rewardMs(~blinkTrial);
contrastR = contrastR(~blinkTrial);
contrastL = contrastL(~blinkTrial);
orientationR = orientationR(~blinkTrial);
orientationL = orientationL(~blinkTrial);
RT = RT(~blinkTrial);

save(['3DLCdat_',trainMatDate ],'pupSizeTrials','licksTrials','eyeCentreTrialsX','eyeCentreTrialsY','stimOnTrials','licksReward','pupSizeReward'...
    ,'base','post','blinkTrial',  'RT',  'contrastR', 'contrastL', 'correct' ,'orientationL' ,'orientationR', 'rewardMs');





