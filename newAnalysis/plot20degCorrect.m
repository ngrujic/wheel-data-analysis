clear all
% close all

titlz = '15-21 days correct rew';
subId =3;

tasks = {'wrongRewardTask','correctRewardTask','accuracyTask'};
% figure
mice = [123 155 160 222 192];
colorz = {'r','g','b'};
unAng = 0:70;


for condInd = 1:3
    cd(['C:\worktemp\Wheel\WheelDat\forRafa\',tasks{condInd}])
    mTable_orig = readtable([tasks{condInd},'.txt']);
    
    for mouseInd = 1:5
        % remove all but wanted mouse
        mTableMouse = mTable_orig;
        mTableMouse(mTableMouse.MouseNr ~= mice(mouseInd),:) = [];
        
        for splitInd = 1:3
            % remove days by splitting index
            totalTrials = length(mTableMouse.Date)
            splitInto(splitInd) = floor(totalTrials/3);
            
            % split all days into 3
            mTable = mTableMouse;
            mTable = mTable(1+splitInto(splitInd)*(splitInd-1) : splitInto(splitInd)*(splitInd),:);
            
            % get all angle differences
            mTable.angDiff = abs(abs(mTable.OrientRight) - abs(mTable.OrientLeft));
            
            % get the mean correct for condition, split, mouse
            meanCorrCondSplitMouse(splitInd,condInd, mouseInd) = mean(mTable.Correct);
            
            % remove 0 deg difference trials
            mTable(mTable.angDiff==0 ,:)= [];
            
            % remove reaction time greater than 3
            mTable(mTable.ReactionTime > 3 ,:) = [];
            
            % remove repeated trials
            mTable(mTable.TrialRepeated == 1 ,:) = [];
            
            % remove high or low level contrast etc
            % mTable(mTable.ContrastLeft + mTable.ContrastRight >=1.1,:) = [];
            
            % get correct angle of the two sides
            resp = mTable.CorrectResponse == 1;
            corrAngle = zeros(height(mTable),1);
            corrAngle(resp) = mTable.OrientRight(resp);
            corrAngle(~resp) = mTable.OrientLeft(~resp);
            
            %%%%% ARRANGE BY CORRECT ANGLE
            unAng = unique(abs(corrAngle));
            corrAngle2 =abs(corrAngle);
            corrAngCorr=[];
            for a = 1:length(unAng)
                
                corrAngCorr(splitInd,a,mouseInd,condInd) = mean(mTable.Correct(corrAngle2 == unAng(a)));
                
                nTrials(splitInd,a,mouseInd,condInd) = length(mTable.Correct(corrAngle2 == unAng(a)));
                
                averageDifficulty(splitInd,a,mouseInd,condInd) = mean(mTable.angDiff(corrAngle2 == unAng(a)));
            end
            
            % %%%%% ARRANGE BY ALL ANGLEs
            % unAng = unique(abs([mTable.OrientRight ; mTable.OrientLeft]));
            % corrAngCorr=[];
            % for a = 1:length(unAng)
            %
            %     corrAngCorr(a) = mean(mTable.Correct(abs(mTable.OrientLeft) == unAng(a) | abs(mTable.OrientRight) == unAng(a)));
            %
            %     nTrials(a,mouseInd,condInd) = length(mTable.Correct(abs(mTable.OrientLeft) == unAng(a) | abs(mTable.OrientRight) == unAng(a)));
            %
            %     averageDifficulty(a) = mean(mTable.angDiff(abs(mTable.OrientLeft) == unAng(a) | abs(mTable.OrientRight) == unAng(a)));
            % end
            
            
            %%%% PLOT PER MOUSE
            % subplot(1,5,mouseInd)
            % hold on
            %
            % plot(unAng,corrAngCorr,'Color',colorz{condInd})
            % title(num2str(mice(mouseInd)))
            
            
        end
        
%         meanMiceSubt(mouseInd,:,condInd) = corrAngCorr -mean(corrAngCorr);
%         meanMice(mouseInd,:,condInd) = corrAngCorr;
    end
    
    
    
    
end

seAngCorr = squeeze(std(meanMice,1)./sqrt(mouseInd));

% figure
% subplot(2,1,1)
% plot(unAng,squeeze(mean(meanMice,1)))
%
% legend(tasks)
% xlabel('Orientation')
% ylabel('Success')
% title('Raw Correct')

subplot(1,3,subId)
plot(unAng,squeeze(mean(meanMiceSubt,1)))

legend(tasks)
xlabel('Orientation')
ylabel('Success')
% title('Mean p correct subtracted')
title(titlz)
% sgtitle(titlz)


