
clear all; close all

M = csvread('222-07202020143735.csv',3,0);
M = [Ml csvread('222-07202020143735.csv',3,0);
load wheel_M222_20-Jul-2020_151547.mat RT
onsets = load('222-07202020.txt');

%% parameters
recFs = 60;
base = 0.15*recFs;
post = 2*recFs;
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
    blinkTrial(onId,:) = min(eyeLikeliTrials(onId,:)) < 0.88;
    
    % arrange variables by onset time
    pupSizeTrials(onId,:) = pupilSize(onsets(onId)-base:onsets(onId)+post) - mean(pupilSize(onsets(onId)-base:onsets(onId)));
    
    licksTrials(onId,:) = licks(onsets(onId)-base:onsets(onId)+post);

    eyeCentreTrialsX(onId,:) = zEyeCentre(onsets(onId)-base:onsets(onId)+post,1) - mean(zEyeCentre(onsets(onId)-base:onsets(onId),1));
    eyeCentreTrialsY(onId,:) = zEyeCentre(onsets(onId)-base:onsets(onId)+post,2) - mean(zEyeCentre(onsets(onId)-base:onsets(onId),2));

    stimOnTrials(onId,:) = stimOn(onsets(onId)-base:onsets(onId)+post);

    % arrange variables by reward time + RT 
    licksReward(onId,:) = licks(onsets(onId) +30 +RTframes(onId) -base : onsets(onId) +30 +RTframes(onId) +post);
    pupSizeReward(onId,:) = pupilSize(onsets(onId) +30 +RTframes(onId) -base : onsets(onId) +30 +RTframes(onId) +post)...
        - mean(pupilSize(onsets(onId)-base:onsets(onId)));

end





save('trialDLCdat_07202020','pupSizeTrials','licksTrials','eyeCentreTrialsX','eyeCentreTrialsY','stimOnTrials','licksReward','pupSizeReward'...
    ,'base','post','blinkTrial');





