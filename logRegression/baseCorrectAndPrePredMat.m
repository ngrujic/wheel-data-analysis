%% prep data for R logistic regression model 
close all; clear all
% load pre arranged struct
load dataTrials.mat

% loop over days 
allPupSize = [];allCorrBasePupSize=[];allBasePupSize=[];allCorrPupSize=[];
for dayInd = 1:length(dayExp)
    
    % here we make big matrix with all trials all sessions
    pupSize = dayExp(dayInd).dlcData.pupilSize;
    allPupSize = [allPupSize; pupSize];
    sessionOnsets(dayInd) = length(allPupSize);
    % get the baseline pupil for all trials 
    basePupSize = mean(pupSize(:,13:base-2),2);  
    allBasePupSize = [allBasePupSize;basePupSize];
    
    
    % get mean of only correct trials of basePupSize
    correct = logical(dayExp(dayInd).expData(:,2));
    corrBasePupSize = basePupSize - mean(basePupSize(correct),1);
    corrPupSize = pupSize - mean(basePupSize(correct),1);
    % here we place the per session corrected matrix by subtracting mean
    % baseline pupil size in CORRECT TRIALS ONLY
    allCorrBasePupSize = [allCorrBasePupSize ; corrBasePupSize];
    allCorrPupSize = [allCorrPupSize; corrPupSize];
    
        % to check each session uncomment
        subplot(1,length(dayExp),dayInd)
        imagesc(pupSize)
        title('raw')
%         subplot(1,2,2)
%         imagesc(corrPupSize)
%         title('corrected')
        caxis([4 8])
end
    
%% %% FOR PLOTTING
    subplot(1,2,1)
    imagesc(allPupSize)
    for a = 1:length(sessionOnsets)
    hold on
   yline(sessionOnsets(a),'r');
    end
%     subplot(1,2,2)
%     imagesc(allCorrPupSize)
%  for a = 1:length(sessionOnsets)
%     hold on
%    yline(sessionOnsets(a),'r');
%     end



figure   
    for a = 1:length(sessionOnsets)
         subplot(1,2,1)
        imagesc(pupSize)
        title('raw')
        subplot(1,2,2)
        imagesc(corrPupSize)
        title('corrected')
    end
