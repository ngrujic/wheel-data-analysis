%% by mouse
close all;
allMiceCorrOr =[];
allMiceCorrNTrials = [];

miceTogether = 1;
incTrialIncrements =60; % to include all increments set to 90 to include just 30 set to 30

if miceTogether ==1
    NInd = 1;
else
    NInd = length(allMiceData)
end

for mouseInd = 1:NInd
    
    if miceTogether == 0
        currMouse = allMiceData{mouseInd,1};
    else
        currMouse = mouseMat;
    end
    
    % filtering by RT < 3 included
    currMouse(currMouse(:,3) > 1,:) = [];
    
    % filtering by repeated trial side
%     currMouse(currMouse(:,5)== 0,:) = [];
    currMouse(currMouse(:,5)== 1 & currMouse(:,6) == 1,:) = [];

    % if we want to filter by correct trial turns -1(leftcorrect) to 0 and
    % 1 to 2 for future indexing
    currMouse(currMouse(:,4) == 1,4) = 0;
    currMouse(:,4)= currMouse(:,4) +2;
    
    %% each Orientation
    uniqueOrients = unique(currMouse(:,end-1:end));
    uniqueOrients = uniqueOrients(1:end-1);
    % loop for all orientation appearances
    for orInd = 1:length(uniqueOrients)
        % conditions for trial inclusion
        [orientTrialInd, y] = find(currMouse(:,end-1:end) == uniqueOrients(orInd)...
            & abs(abs(currMouse(:,end-1))-abs(currMouse(:,end))) <= incTrialIncrements);
        
        percorrOrient(orInd) = sum(currMouse(orientTrialInd,2))/length(orientTrialInd);
        nTrialsOr(orInd) = length(orientTrialInd);
        
    end
    
    figure(1)
    if miceTogether == 0
        subplot(2,3,mouseInd)
    end
    bar( 0.825:length(percorrOrient),percorrOrient,0.25 )
    xticks(1:length(percorrOrient))
    xticklabels(uniqueOrients)
    ylim([0 1])
    ylabel('Correct over 0.5')
    xlabel('Orientation appears')
    hold on
    yyaxis right
    ylabel('N Trials')
    bar( 1.125:length(nTrialsOr)+0.125,nTrialsOr,0.25)
      if miceTogether == 0
        title(['All Orientations - ',allMiceData{mouseInd,2}])
    else
        title(['All Orientations - All Mice'])
    end
    
    
    %% looking at only the correct orient appearance
    % make corr orient matrix;
    corrOrient = zeros(length(currMouse),1);
    corrOrient(currMouse(:,4) == 1,1) = currMouse(currMouse(:,4) == 1,end-1); %left
    corrOrient(currMouse(:,4) == 2,1) = currMouse(currMouse(:,4) == 2,end); % right correct
    unCorrOr = unique(corrOrient);
    
    for orInd = 1:length(unCorrOr)
        
        [orientTrialInd, y] = find(corrOrient == unCorrOr(orInd)...
            & abs(abs(currMouse(:,end-1))-abs(currMouse(:,end))) <= incTrialIncrements );
        
        perOnlyCorrOrient(orInd) = sum(currMouse(orientTrialInd,2))/length(orientTrialInd);
        
        
        nTrialsCorrOr(orInd) = (length(orientTrialInd)*nTrialsOr(orInd))/nTrialsOr(orInd);
        
        
    end
    
    figure(2)
    if miceTogether == 0
        subplot(2,3,mouseInd)
    end
    bar( 0.825:length(perOnlyCorrOrient),perOnlyCorrOrient,0.25 )
    xticks(1:length(perOnlyCorrOrient)); xticklabels(uniqueOrients)
    ylim([0 1])
    ylabel('pCorrect')
    xlabel('Orientation appears')
    hold on
    yyaxis right
    ylabel('Percent of trials particulat orient is awarded')
    bar( 1.125:length(nTrialsCorrOr)+0.125,nTrialsCorrOr,0.25)
    
     if miceTogether == 0
        title(['Only correct Orientations - ',allMiceData{mouseInd,2}])
    else
        title(['Only correct Orientations - All Mice'])
    end
    
    % SCATTERPLOT PER MOUSE
    % %     figure(3)
    % %     hold on
    % %     scatter(nTrialsCorrOr,perOnlyCorrOrient)
    % %     ylabel('N Trials');xlabel('Orientation appears')
    
    
    allMiceCorrOr = [allMiceCorrOr; perOnlyCorrOrient];
    allMiceCorrNTrials = [allMiceCorrNTrials; nTrialsCorrOr];
    
    %     [RHO,PVAL] = corrcoef(nTrialsCorrOr,perOnlyCorrOrient);
    %     rVal(mouseInd) = RHO(1,2);
    %     pVal(mouseInd) = PVAL(1,2);
    
end
%   legend(allMiceData{:,2})
%     lsline; ylim([0 1])

%% plotting scatterplot for all orientations and all mice things
% allMiceCorrOr = reshape(allMiceCorrOr,1,numel(allMiceCorrOr));
% allMiceCorrNTrials = reshape(allMiceCorrNTrials,1,numel(allMiceCorrNTrials));
%  figure(4)
%  scatter(allMiceCorrNTrials,allMiceCorrOr-0.5)
%     lsline; ylim([0 0.5])
% ylabel('Correct over 0.5');xlabel('Orientation Trials')
% [r p] = corrcoef(allMiceCorrOr,allMiceCorrNTrials);

