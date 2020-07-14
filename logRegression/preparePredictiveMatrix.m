%% hierarchical logistic regression

% calculate prior info for each orientation
orients = unique(mouseMat(:,11))

priorVal = zeros(length(mouseMat),1);
for i = 1:length(orients)
    
    %left orient
    lOrIdx = mouseMat(:,11) == orients(i);
    lOrCorrIdx = mouseMat(:,11) == orients(i) &  mouseMat(:,3) == 1;
    leftOr(i) = length(mouseMat(lOrIdx,:))/length(mouseMat);
    
    % right orient
    rOrIdx = mouseMat(:,12) == orients(i);
    rOrCorrIdx = mouseMat(:,12) == orients(i) &  mouseMat(:,3) == 1;
    rightOr(i) = length(mouseMat(rOrIdx,:))/length(mouseMat);
    rightCorrOr(i) = length(mouseMat(rOrCorrIdx,:))/length(mouseMat);

    
    priorVal(lOrIdx,1) = priorVal(lOrIdx,1) + leftOr(i);
    priorVal(rOrIdx,1) = priorVal(rOrIdx,1) + rightOr(i);
end

% filter trials by different things in conditionIdx
conditionIdx = mouseMat(:,4)<3 & mouseMat(:,8) == 0;
filteredDat = mouseMat(conditionIdx,:);
filtPriorVal = priorVal(conditionIdx,:);
% answer variable
feedback = categprical(filteredDat(:,3));

% make the predictor matrix
contrastLR = zscore(filteredDat(:,14)-filteredDat(:,13));
orientDiff = zscore(abs(filteredDat(:,11))-abs(filteredDat(:,12)));
filtPriorVal= zscore(filtPriorVal);

X = [orientDiff filtPriorVal];

[B,dev,stats] = mnrfit(X ,categorical(feedback),'model','hierarchical');

prediction = mnrval(B,X,stats);
