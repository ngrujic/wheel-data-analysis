function [eyeCentre, pupilSize,eyesLikelihood,licks,eyePointDistances] = getPupilSizePositionCSV(M)
% Input loaded csv file data from DLC model ALL eyez on me by Nik

%% eyes x and y positions and  EYE centre

for eyes = 0:7

eyesX(:,1+eyes) = M(:,2+eyes*3);
eyesY(:,1+eyes) = M(:,3+eyes*3);
eyesLikelihood(:,1+eyes) = M(:,4 + eyes*3);
end
% keyboard
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

    
    
    % pythagoras for each position with each other position
%     keyboard

    eyePointDistances = sqrt((eyesX(:,1:4) - eyesX(:,5:8)).^2 ...
        +((eyesY(:,1:4) - eyesY(:,5:8))).^2);

%         pupilSize(:,i) = polyarea(eyesX(i,:),eyesY(i,:));

pupilSize = (mean(eyePointDistances,2));
% pupilSize = eyePointDistances(:,3);


end