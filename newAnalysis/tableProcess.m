%% plotting averages for wheel data

mTable = readtable('wrongRewTask.txt');

mice = unique(mTable.MouseNr);

mTable.orientDiffs = abs(mTable.OrientLeft) - abs(mTable.OrientRight);
mTable.sumContrast = mTable.ContrastLeft + mTable.ContrastRight;
mTable.contrastDiff = mTable.Contrast
% breaking the table
for mouseInd = 1:length(mice)
    
    % get for mouse
    mouseTab = mTable(mTable.MouseNr == mice(mouseInd),:);
    
    % remove the trials that were repeated
    mouseTab = mouseTab(mouseTab.TrialRepeated == 0,:);
    
    % remove the trials that were during the habituation period
    mouseTab = mouseTab(mouseTab.Date > 5,:);
    
    
    
    
    
    
    keyboard
end