function [eyeCentre, pupilSize,eyesLikelihood,licks] = getPupilSizePositionCSV(M)
% Input loaded csv file data from DLC model ALL eyez on me by Nik

%% eyes x and y positions and  EYE centre

for eyes = 0:7

eyesX(:,1+eyes) = M(:,2+eyes*3);
eyesY(:,1+eyes) = M(:,3+eyes*3);
eyesLikelihood(:,1+eyes) = M(:,4 + eyes*3);
end

% for blink detection eye likelihood
% eyesLikelihood = mean(eyesLikelihood,2);

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

pupilSize = (mean(eyePointDistances,2));
end