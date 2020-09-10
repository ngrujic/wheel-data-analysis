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
for a = 1:nRecs
    % training day
    if iscell(dayz)
    csvfile = cell2mat(dayz(a));
    else
        csvfile =dayz;
    end
    trainMatDate = datenum(csvfile(5:12), 'mmddyyyy');
    trainMatText = datestr(trainMatDate,'dd-mmm-yyyy');
    csvDate = csvfile(5:12); 
    
    % actually read from correct files
    % read the csv file
    csvFile = dir(['*' csvDate '*.csv']);
    M = [M; csvread(csvFile.name,3,0)];
    recFramesLength(a) = length(csvread(csvFile.name,3,0));
    
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

end

% convert reaction times to frame time
RTframes = round(RT*recFs);

%% Try to use DLC detection for the onset detection

onsetAnalog = M(:,31);

[onsetSecs, onsets] = getanalogsignalonsets(onsetAnalog,0.7,60,1.1,0,[],0);


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

save(['DLCdat_',trainMatDate ],'pupSizeTrials','licksTrials','eyeCentreTrialsX','eyeCentreTrialsY','stimOnTrials','licksReward','pupSizeReward'...
    ,'base','post','blinkTrial',  'RT',  'contrastR', 'contrastL', 'correct' ,'orientationL' ,'orientationR', 'rewardMs');





