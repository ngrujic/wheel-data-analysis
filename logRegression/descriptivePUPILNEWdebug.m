%% ARRANGE DATA

condition = 'reflectionFiltered';
align_to_rew = 0;

cd(['C:\worktemp\Wheel\pupilDat\newModelCorrectRew\',condition])
if align_to_rew == 0
    load([condition, '_dataTrials.mat'])
else
    load([condition, '_dataTrialsReward.mat'])
end
%%
currDate = 0;
expTrials =[];pupilTrials=[];

for i = 1:length(dayExpTrials)
    tempDLC = dayExpTrials(i).dlcData.pupilSize;
    
%     close all
%     figure;
%     subplot(2,1,1)
% %     plot(reshape(tempDLC',size(tempDLC,1)*226,1))
% %     % z scoring here
%     reshapedPup = zscore(reshape(tempDLC',size(tempDLC,1)*226,1));
% %     subplot(2,1,2)
% %     plot(reshapedPup);
% %     keyboard
%     
%     reshapedPup = reshape(reshapedPup,size(tempDLC,1),226);
%     dayExp(i).date
% %     close all
    
    %%%%%%%%%% PLOT TEST %%%%%%%%%%%
%     close all
%     figure(3)
%     subplot(2,1,1)
%     mouseDiffsAll = mean(tempDLC,1);
%     plot((1:size(mouseDiffsAll,2))/60 -0.75,mouseDiffsAll,'k')
%     hold on
%     xline(0)
%     %         title(num2str(uniMice(i)))
% %     ylim([-0.5 0.5])
%     sgtitle(num2str(dayExp(i).expData(1,13)))
%     subplot(2,1,2)
%     imagesc(tempDLC)
%     caxis([-1 1])
%     keyboard
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    pupilTrials = [pupilTrials; tempDLC];
    expTrials = [expTrials; dayExpTrials(i).expData];
    
end

% remove weird 10 deg difference trials
pupilTrials(expTrials(:,12)==10,:)= [];
expTrials(expTrials(:,12)==10,:)= [];
% 
% % remove repeated trials
% pupilTrials(expTrials(:,10)==1,:)= [];
% expTrials(expTrials(:,10)==1,:)= [];

% remove RT < 0.1 trials
% pupilTrials(expTrials(:,11)<0.5,:)= [];
% expTrials(expTrials(:,11)<0.5,:)= [];

% remove RT > 3 trials
% pupilTrials(expTrials(:,11)>3,:)= [];
% expTrials(expTrials(:,11)>3,:)= [];

figure
plot(mean(pupilTrials(expTrials(:,2)==1,:),1),'g')
hold on
plot(mean(pupilTrials(expTrials(:,2)==0,:),1),'r')
xline(base)

%% GET AVERAGES FOR EACH MOUSE
% close all
uniMice = unique(expTrials(:,13));
uniDiff = unique(expTrials(:,12));

for i = 1:length(uniMice)
    
    oneMouseAllTrials = pupilTrials(expTrials(:,13) == uniMice(i),:);
    
    for j = 1:length(uniDiff)
        oneMouseCorrect = pupilTrials(expTrials(:,13) == uniMice(i) & expTrials(:,2) == 1 & expTrials(:,12) == uniDiff(j),:);
        oneMouseInCorrect = pupilTrials(expTrials(:,13) == uniMice(i) & expTrials(:,2) == 0 & expTrials(:,12) == uniDiff(j),:);
        %
        %%% IF YOU WANNA PLOT
        figure(1)
        subplot(1,9,j)
        plot((1:size(oneMouseCorrect,2))/60 -0.75,(mean(oneMouseCorrect,1)),'g')
        hold on
        plot((1:size(oneMouseCorrect,2))/60 -0.75,(mean(oneMouseInCorrect,1)),'r')
        hold on
        xline(0)
        sgtitle(num2str(uniMice(i)))
        title(['absAngDiff = ',num2str(uniDiff(j))])
        ylim([-0.4 0.8])
        
        % correct and incorrect averages
        mouseDiffsC(j,:,i) = mean(oneMouseCorrect,1);
        mouseDiffsI(j,:,i) = mean(oneMouseInCorrect,1);
    end
    %        figure(19)
    %         mouseDiffsAll(i,:) = mean(oneMouseAllTrials,1);
    %         subplot(1,5,i)
    %         plot((1:size(mouseDiffsAll,2))/60 -0.75,mouseDiffsAll(i,:),'k')
    %         hold on
    %         xline(0)
    %         title(num2str(uniMice(i)))
    %         ylim([-0.5 0.5])
    %         sgtitle(condition)
end

%% Plot averages across mice
allMeanC = mean(mouseDiffsC,3);
allMeanI = mean(mouseDiffsI,3);

for j = 1:9

    figure(6)
    subplot(1,9,j)
    plot((1:size(allMeanC(j,:),2))/60-0.75,(allMeanC(j,:)),'g')
    hold on
    plot((1:size(allMeanI(j,:),2))/60-0.75, (allMeanI(j,:)),'r')
    hold on
    xline(0)
    ylim([-0.5 0.8])
    %       sgtitle(num2str(uniMice(i)))
%     ylim([-0.3 0.6])
end

%% Save for R plotting Figure 3 - averages of all trials for each condition
% correct incorrect doesn't matter here
if align_to_rew == 0
    save([condition,'Pupil.mat'],'pupilTrials','expTrials')
else
    save([condition,'PupilReward.mat'],'pupilTrials','expTrials')
end

% plot to check what it looks like
% figure(7)
%
% plot((1:size(mouseDiffsAll,2))/60-0.75,mean(mouseDiffsAll,1))
% hold on; xline(0)

















