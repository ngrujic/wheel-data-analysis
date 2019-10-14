%% Calculates the percent success for all orientations
clear all
close all

[file,path] = uigetfile;
load([path,file])

orients = [block.paramsValues.stimulusOrientation].';
orientTypes = unique(orients);
feedback = block.events.feedbackValues;

for i = 1:length(orientTypes)

    orientInd = find(orients == orientTypes(i));
    
    orientCorrect(i) = sum(feedback(orientInd))/length(feedback(orientInd));
    
end

figure(1)
plot(orientTypes,orientCorrect)