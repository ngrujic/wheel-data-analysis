clear all
close all

tasks = {'wrongRewardTask','correctRewardTask','accuracyTask'};
% figure
mice = [123 155 160 222 192];
colorz = {'r','g','b'};

Nstages =4;

for condInd = 1:length(tasks)
    cd(['C:\worktemp\Wheel\WheelDat\forRafa\',tasks{condInd}])
    mTable_orig = readtable([tasks{condInd},'.txt']);
    
    for mouseInd = 1:length(mice)
        % remove all but wanted mouse
        mTableMouse = mTable_orig;
        mTableMouse(mTableMouse.MouseNr ~= mice(mouseInd),:) = [];
        
        for splitInd = 1:Nstages
            % remove days by splitting index
            totalTrials = length(mTableMouse.Date)
            splitInto(splitInd) = floor(totalTrials/Nstages);
            
            % split all days into stages
            mTable = mTableMouse;
            mTable = mTable(1+splitInto(splitInd)*(splitInd-1) : splitInto(splitInd)*(splitInd),:);
            
            % get all angle differences
            mTable.angDiff = abs(abs(mTable.OrientRight) - abs(mTable.OrientLeft));
            
            % get the mean correct for condition, split, mouse
            meanCorrCondSplitMouse(splitInd,condInd, mouseInd) = mean(mTable.Correct);
            
            % remove 0 deg difference trials
            mTable(mTable.angDiff ==0 ,:)= [];
            
            % remove reaction time greater than 3
            mTable(mTable.ReactionTime > 3 ,:) = [];
            
            % remove repeated trials
            mTable(mTable.TrialRepeated == 1 ,:) = [];
            
            % remove dates manually
%             mTable(mTable.Date <8,:) = [];
            
            % remove high or low level contrast etc
            mTable(mTable.ContrastLeft + mTable.ContrastRight >=1,:) = [];
            
            % get correct angle of the two sides
            resp = mTable.CorrectResponse == 1;
            corrAngle = zeros(height(mTable),1);
            corrAngle(resp) = mTable.OrientRight(resp);
            corrAngle(~resp) = mTable.OrientLeft(~resp);
            
            %%%%% ARRANGE BY CORRECT ANGLE
            corrAngle2 =abs(corrAngle);
            
            corrAngle2(corrAngle2 >=0 & corrAngle2<=10) = 1;
            corrAngle2(corrAngle2 >=20 & corrAngle2<=30) = 2;
            corrAngle2(corrAngle2 >=40 & corrAngle2<=50) = 3;
corrAngle2(corrAngle2 >=60 & corrAngle2<=70) = 4;

            unAng = unique(corrAngle2);
            for a = 1:length(unAng)
                
                corrAngCorr(splitInd,a,mouseInd,condInd) = mean(mTable.Correct(corrAngle2 == unAng(a)));
                
                corrAngCorrBaselined(splitInd,a,mouseInd,condInd) = mean(mTable.Correct(corrAngle2 == unAng(a)))...
                    - meanCorrCondSplitMouse(splitInd,condInd, mouseInd);

                
                nTrials(splitInd,a,mouseInd,condInd) = length(mTable.Correct(corrAngle2 == unAng(a)));
                
                averageDifficulty(splitInd,a,mouseInd,condInd) = mean(mTable.angDiff(corrAngle2 == unAng(a)));
            end
            
            % for removing the average of the average corrects 
             corrAngCorrSubt(splitInd,:,mouseInd,condInd) = corrAngCorr(splitInd,:,mouseInd,condInd) - mean(corrAngCorr(splitInd,:,mouseInd,condInd),2);
%              
             
            %%%%% ARRANGE BY ALL ANGLEs
%             unAng = unique(abs([mTable.OrientRight ; mTable.OrientLeft]));
% %             corrAngCorr=[];
%             for a = 1:length(unAng)
%             
%                 corrAngCorr(splitInd,a,mouseInd,condInd) = mean(mTable.Correct(abs(mTable.OrientLeft) == unAng(a) | abs(mTable.OrientRight) == unAng(a)));
%             
%                 nTrials(splitInd,a,mouseInd,condInd) = length(mTable.Correct(abs(mTable.OrientLeft) == unAng(a) | abs(mTable.OrientRight) == unAng(a)));
%             
%                 averageDifficulty(splitInd,a,mouseInd,condInd)  = mean(mTable.angDiff(abs(mTable.OrientLeft) == unAng(a) | abs(mTable.OrientRight) == unAng(a)));
%             end
%             
%                 corrAngCorrSubt(splitInd,:,mouseInd,condInd) = corrAngCorr(splitInd,:,mouseInd,condInd) ./ mean(corrAngCorr(splitInd,:,mouseInd,condInd),2);

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
%% averageing plotting etc..
figure(1)
% take mean across mice
acrossMice = (mean(corrAngCorrSubt,3));

% color vector for plotting

% plot
for cond2 = 1:length(tasks)
%     subplot(1,3,cond2)
%     title(tasks{cond2})

   for stage = Nstages
%               colorVec =  [ 1 1 1]*( 1- 0.25*cond2);


      vecToPlot = (acrossMice(stage,:,cond2));
      hold on
      plot(unAng,vecToPlot,'Color',colorz{cond2})
       
      
   end
end
    sgtitle('Last third trials of each condition')
    legend(tasks)
    
%% wrong rew - correct rew
% close all
% figure
% vecToPlot = squeeze(acrossMice(stage,:,2) - acrossMice(stage,:,1))*100;
% plot(vecToPlot)

% vecToPlot = squeeze(acrossMice(3,:,2) - acrossMice(3,:,1))*100;
% plot(vecToPlot)


