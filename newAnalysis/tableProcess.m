%% plotting averages for wheel data
clear all
close all
tasks = {'wrongRewardTask','correctRewardTask','accuracyTask'};

for condInd = 1:3
    cd(['C:\worktemp\Wheel\WheelDat\forRafa\',tasks{condInd}])
    mTable = readtable([tasks{condInd},'.txt']);
    
    mTable(mTable.Date < 1,:) = [];
    
    
    mTable.orientDiffs = abs(mTable.OrientLeft) - abs(mTable.OrientRight);
    mTable(abs(mTable.orientDiffs) == 10,:) = [];
    
    mTable.sumContrast = mTable.ContrastLeft + mTable.ContrastRight;
    mTable.contrastDiff = mTable.ContrastLeft - mTable.ContrastRight;
    
    uniqOrd = unique(abs(mTable.orientDiffs));
    uniqCont = unique(mTable.contrastDiff);
    
    % exclude shit biased mouse
    mTable(mTable.MouseNr == 192,:) = [];
    mice = unique(mTable.MouseNr);
    
    
    % breaking the table
    for mouseInd = 1:length(mice)
        newMice{mouseInd} = num2str(mice(mouseInd));
        % get for mouse
        mouseTab = mTable(mTable.MouseNr == mice(mouseInd),:);
        
        % remove the trials that were repeated
        mouseTab = mouseTab(mouseTab.TrialRepeated == 0,:);
        
        % remove the trials that were during the habituation period
        mouseTab = mouseTab(mouseTab.Date > 5,:);
        
        
        %% for each orientation difference split
        for ordInd = 1:length(uniqOrd)
            
            ordTab = mouseTab(abs(mouseTab.orientDiffs) == uniqOrd(ordInd),:);
            
            mouseMeanSucc(mouseInd,ordInd) = mean(ordTab.Correct);
            
            mouseMeanResp(mouseInd,ordInd) = sum(ordTab.Response == -1)/size(ordTab,1);
            
            
            %             % for each contrast within diff difference split it
            %             for contOrdInd = 1:length(uniqCont)
            %                 contOrdTab = ordTab(ordTab.contrastDiff == uniqCont(contOrdInd),:);
            %
            %                 mouseMeanContOrdSucc(contOrdInd,ordInd,mouseInd) = mean(contOrdTab.Correct);
            %
            %                 mouseMeanContOrdResp(contOrdInd,ordInd,mouseInd) = sum(contOrdTab.Response == -1)/size(contOrdTab,1);
            %             end
            % for each contrast sum
            unSums = unique(ordTab.sumContrast);
            
            contOrdTab = ordTab(ordTab.sumContrast <= 0.9,:);
            contOrdTab2 = ordTab(ordTab.sumContrast >= 1.6,:);
            
            mouseMeanContOrdSucc(1,ordInd,mouseInd) = mean(contOrdTab.Correct);
            mouseMeanContOrdSucc(2,ordInd,mouseInd) = mean(contOrdTab2.Correct);
            
            mouseMeanContOrdResp(1,ordInd,mouseInd) = sum(contOrdTab.Response == -1)/size(contOrdTab,1);
            mouseMeanContOrdResp(2,ordInd,mouseInd) = sum(contOrdTab2.Response == -1)/size(contOrdTab2,1);
            
            
            
            
        end
        
        
        
        %% for each contrast difference split it
        for contInd = 1:length(uniqCont)
            contTab = mouseTab(mouseTab.sumContrast == uniqCont(contInd),:);
            
            mouseMeanContSucc(mouseInd,contInd) = mean(contTab.Correct);
            
            mouseMeanContResp(mouseInd,contInd) = sum(contTab.Response == -1)/size(contTab,1);
        end
        
        %% plotting in loop
        figure(100+condInd)
        subplot(1,4,mouseInd)
        plot(uniqOrd, mouseMeanContOrdSucc(:,:,mouseInd))
        xticks(uniqOrd)
        xticklabels(uniqOrd)
        ylim([0.4 1])
        title(mice(mouseInd))
        
        if mouseInd == length(mice)
            legend('low c','high c')
            sgtitle(tasks{condInd})
        end
    end
    
    %% PLOT OR NOT
    plotall=0
    if plotall
        figure(1)
        subplot(1,3,condInd)
        plot(mouseMeanResp')
        title(tasks{condInd})
        xticks(1:length(mouseMeanResp'))
        xticklabels(uniqOrd)
        ylabel('pTurnLeft')
        xlabel('Angle Diff')
        xline(9)
        yline(0.5)
        legend(newMice)
        
        meanRespAll = mean(mouseMeanResp,1);
        stdRespAll = std(mouseMeanResp,0,1);
        SErespAll = 2*stdRespAll/sqrt(length(mice));
        
        figure(2)
        colorz = {'r','g','b'}
        hold on
        shadedErrorBar(1:length(meanRespAll),meanRespAll,SErespAll,'lineProps',colorz(condInd),'patchSaturation',0.08)
        title('Averages per Condition')
        xticks(1:length(mouseMeanResp'))
        xticklabels(uniqOrd)
        ylabel('pTurnLeft')
        xlabel('Angle Diff')
        ylim([0 1])
        xline(9)
        yline(0.5)
        legend(tasks)
        
        meanRespAll = mean(mouseMeanContResp,1);
        stdRespAll = std(mouseMeanContResp,0,1);
        SErespAll = 2*stdRespAll/sqrt(length(mice));
        
        figure(3)
        subplot(1,3,condInd)
        plot(mouseMeanContResp')
        title(tasks{condInd})
        xticks(1:7)
        xticklabels(uniqCont)
        ylabel('pTurnLeft')
        xlabel('Contrast (L-R)')
        xline(4)
        yline(0.5)
        legend(newMice)
        ylim([0 1])
        
        figure(4)
        hold on
        shadedErrorBar(1:length(meanRespAll),meanRespAll,SErespAll,'lineProps',colorz(condInd),'patchSaturation',0.08)
        title('Averages per Condition')
        xticks(1:length(mouseMeanResp'))
        xticklabels(uniqCont)
        ylabel('pTurnLeft')
        xlabel('Contrast Diff')
        ylim([0 1])
        xline(4)
        yline(0.5)
        legend(tasks)
        
        for mouseInd = 1:length(mice)
            
            figure(5+condInd)
            subplot(4,1,mouseInd)
            imagesc(mouseMeanContOrdResp(:,:,mouseInd))
            sgtitle(tasks{condInd})
            xticks(1:length(mouseMeanResp'))
            xticklabels(uniqOrd)
            ylabel('Contrast Diff')
            xlabel('Angle Diff')
            title(newMice{mouseInd})
            caxis([0 1])
        end
    end
end






