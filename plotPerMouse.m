%% by mouse
close all;
allMiceCorrOr =[];
allMiceCorrNTrials = [];

for mouseInd = 1:length(allMiceData)
    
    currMouse = allMiceData{mouseInd,1};
    %     currMouse = mouseMat;
    
    % filtering by RT < 3 included
    currMouse(currMouse(:,3) > 3,:) = [];
    
    % filter by condition
    currMouse(currMouse(:,8) == 1,:) = [];
    
    % if we want to filter by correct trial turns -1(leftcorrect) to 0 and
    % 1 to 2 for future indexing
    %     currMouse(currMouse(:,4) == 1,4) = 0;
    %     currMouse(:,4)= currMouse(:,4) +2;
    
    % each Orientation
    uniqueOrients = unique(currMouse(:,end-1:end));
    uniqueOrients = uniqueOrients(1:end-1);
    
    % make 11th column of mice the difference between orientations
    % (difficulty)
    currMouse(:,11) = abs(abs(currMouse(:,9))-abs(currMouse(:,10)));
    
    uniqueIncrements =  unique(currMouse(:,end));
    
    
    % find different increments and loop
    for incrementInd = 1:length(uniqueIncrements)
        
        % loop for all orientation appearances
        for orInd = 1:length(uniqueOrients)
            
            % conditions for trial inclusion
            [orientTrialInd, y] = find(currMouse(:,9:10) == uniqueOrients(orInd)...
                & currMouse(:,end) == uniqueIncrements(incrementInd) ...
                &  currMouse(:,6) ==0);
            
            percorrOrient(orInd,incrementInd) = sum(currMouse(orientTrialInd,2))/length(orientTrialInd);
            nTrialsOr(orInd,incrementInd) = length(orientTrialInd);
            
        end
    end
    
    figure(1)
    subplot(2,3,mouseInd)
    bar( 0.825:length(percorrOrient),percorrOrient-0.5,0.25 )
    xticks(1:length(percorrOrient))
    xticklabels(uniqueOrients)
    title(['All Orientations - ',allMiceData{mouseInd,2}])
    ylim([0 0.3])
    ylabel('Correct over 0.5')
    xlabel('Orientation appears')
    hold on
    yyaxis right
    ylabel('N Trials')
    bar( 1.125:length(nTrialsOr)+0.125,nTrialsOr,0.25)
    
end


%% looking at only the correct orient appearance

for mouseInd = 1:length(allMiceData)
    % make corr orient matrix;
    corrOrient = zeros(length(currMouse),1);
    corrOrient(currMouse(:,4) == 1,1) = currMouse(currMouse(:,4) == 1,end-1); %left
    corrOrient(currMouse(:,4) == 2,1) = currMouse(currMouse(:,4) == 2,end); % right correct
    unCorrOr = unique(corrOrient);
    
    for orInd = 1:length(unCorrOr)
        
        [orientTrialInd, y] = find(corrOrient == unCorrOr(orInd)...
            ...%       & abs(abs(currMouse(:,end-1))-abs(currMouse(:,end))) ==30 ...
            & (currMouse(:,5) == 0| currMouse(:,6) ==0));
        
        perOnlyCorrOrient(orInd) = sum(currMouse(orientTrialInd,2))/length(orientTrialInd);
        nTrialsCorrOr(orInd) = (length(orientTrialInd))/nTrialsOr(orInd);
    end
    
    figure(2)
    subplot(2,3,mouseInd)
    bar( 0.825:length(perOnlyCorrOrient),perOnlyCorrOrient-0.5,0.25 )
    xticks(1:length(perOnlyCorrOrient)); xticklabels(uniqueOrients)
    title(['Only correct Orientations - ',allMiceData{mouseInd,2}])
    ylim([0 0.3])
    ylabel('Correct over 0.5')
    xlabel('Orientation appears')
    hold on
    yyaxis right
    ylabel('Percent of trials particulat orient is awarded')
    bar( 1.125:length(nTrialsCorrOr)+0.125,nTrialsCorrOr,0.25)
    
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

