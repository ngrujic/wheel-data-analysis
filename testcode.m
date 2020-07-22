%% by mouse
close all;
allMiceCorrOr =[];
allMiceCorrNTrials = [];

for mouseInd = 1:length(allMiceData)
  mouseInd = 1:length(allMiceData)
    
%     currMouse = allMiceData{mouseInd,1};
        currMouse = mouseMat;
    
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
    
    % sort out the predictors
    
    
end
