%% check contrasts

% filter trials by different things in conditionIdx
conditionIdx = mouseMat(:,7) ==0;
filteredDat = mouseMat(conditionIdx,:);

% filteredDat = filteredDat(40781:end,:);

% unique mice
uniqueMice = unique(filteredDat(:,1))
% contrasts filter
contrastLR = filteredDat(:,14)-filteredDat(:,13);
contrastsUn = unique(contrastLR);

%% first
condMeanCorr=[];condMeanSideL=[];
% loop to extract by condition
for i = 1:length(contrastsUn)
    
    condTempDat = filteredDat(contrastLR == contrastsUn(i),:);
    
    condMeanCorr(i) = mean(condTempDat(:,3));
    
    condMeanSideL(i) = mean(condTempDat(:,6) == -1);
    
    
end

plot(condMeanCorr)
hold on
plot(condMeanSideL)
xticklabels(contrastsUn)

%% check with orient differences


% orientations filter
orientDiff = abs(filteredDat(:,11))-abs(filteredDat(:,12));
orientDiffUn = unique(orientDiff);

condMeanCorr=[];condMeanSideL=[];
% loop to extract by condition
for i = 1:length(orientDiffUn)
    
    condTempDat = filteredDat(orientDiff == orientDiffUn(i),:);
    
    condMeanCorr(i) = mean(condTempDat(:,3));
    
    condMeanSideL(i) = mean(condTempDat(:,6) == -1);
    
    
end
figure
plot(condMeanCorr)
hold on
plot(condMeanSideL)
xticks([1:length(orientDiffUn)])
xticklabels(orientDiffUn)

%% check with both orient differences and contrast
close all
condMeanCorr=[];condMeanSideL=[];
% loop to extract by condition
for a = 1:length(uniqueMice)
    
    
    for i = 1:length(orientDiffUn)
        
        for ii = 1:length(contrastsUn)
            
            condTempDat = filteredDat(filteredDat(:,1) == a & orientDiff == orientDiffUn(i) & contrastLR == contrastsUn(ii),:);
            
            condMeanCorr(ii,i,a) = mean(condTempDat(:,3));
            
            condMeanSideL(ii,i,a) = mean(condTempDat(:,6) == -1);
            
            nTrials(ii,i,a) = size(condTempDat,1);
        end
        
    end

%
figure(a)
imagesc(condMeanSideL(:,:,a)')
c=colorbar;c.Label.String='Percent Chose R'; colormap('jet')
yticks([1:length(orientDiffUn)])
yticklabels(orientDiffUn)
xticks([1:length(condMeanSideL)])
xticklabels(contrastsUn)
xlabel('contrast(R-L)')
ylabel('orientation (L-R)')


contmarks= {'-0.7';'-0.4';'-0.3';'0';'0.3';'0.4';'0.7'};
figure(length(uniqueMice)+a)
for i = 1:size(condMeanCorr,1)
    
    plot(condMeanCorr(i,:,a),'Color',[i/size(condMeanCorr,1),i/size(condMeanCorr,1),i/size(condMeanCorr,1)])
    hold on
    
end
legend(contmarks)
end


%% check with both orient differences and contrast

condMeanCorr=[];condMeanSideL=[];
% loop to extract by condition
orientDiffUn2 = orientDiffUn
clear nTrials condMeanSideL condMeanCorr 
    
    for i = 1:length(orientDiffUn2)
        
        for ii = 1:length(contrastsUn)
            
            condTempDat = filteredDat(orientDiff == orientDiffUn2(i) & contrastLR == contrastsUn(ii),:);
            
            condMeanCorr(ii,i) = mean(condTempDat(:,3));
            
            condMeanSideL(ii,i) = mean(condTempDat(:,6) == -1);
            
            nTrials(ii,i) = size(condTempDat,1);
        end
        
    end

%
figure(a)
imagesc(condMeanSideL(:,:,a)')
c=colorbar;c.Label.String='Percent Chose R'; colormap('jet')
yticks([1:length(orientDiffUn2)])
yticklabels(orientDiffUn2)
xticks([1:length(condMeanSideL)])
xticklabels(contrastsUn)
xlabel('contrast(R-L)')
ylabel('orientation (L-R)')


contmarks= {'-0.7';'-0.4';'-0.3';'0';'0.3';'0.4';'0.7'};
figure(length(uniqueMice)+a)
for i = 1:size(condMeanCorr,1)
    
    plot(condMeanCorr(i,:,a),'Color',[i/size(condMeanCorr,1),i/size(condMeanCorr,1),i/size(condMeanCorr,1)])
    hold on
    
end
legend(contmarks)
