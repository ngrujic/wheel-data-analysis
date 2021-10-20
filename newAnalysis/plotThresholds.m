clear all
close all

titlz = 'binned'

tasks = {'wrongRewardTask','correctRewardTask','accuracyTask'};
figure
mice = [123 155 160 222 192];
colorz = {'r','g','b'};
unAng = 0:70;
for condInd = 1:3
    for mouseInd = 1:5
        
        
        
        
        cd(['C:\worktemp\Wheel\WheelDat\forRafa\',tasks{condInd}])
        mTable_orig = readtable([tasks{condInd},'.txt']);
        mTable = mTable_orig;
        mTable.angDiff = abs(abs(mTable.OrientRight) - abs(mTable.OrientLeft));
        
        mTable(mTable.MouseNr ~= mice(mouseInd),:) = [];
        
        mTable(mTable.angDiff<=10 ,:)= [];
        mTable(mTable.Date < 8 ,:) = [];
        mTable(mTable.ReactionTime > 3 ,:) = [];
%         mTable(mTable.TrialRepeated == 1 ,:) = [];
                mTable(mTable.ContrastLeft + mTable.ContrastRight >1.1 ,:) = [];
        
        
        %%%% get the correct side angle
        resp = mTable.CorrectResponse == 1;
        corrAngle = zeros(height(mTable),1);
        corrAngle(resp) = mTable.OrientRight(resp);
        corrAngle(~resp) = mTable.OrientLeft(~resp);
        
        %%%%%%%%%    ARRANGE BY CORRECT ANGLE
        % % % % % % unAng = unique(abs(corrAngle));
        % % % % % % corrAngle2 =abs(corrAngle);
        % % % % % % corrAngCorr=[];
        % % % % % % for a = 1:length(unAng)
        % % % % % %
        % % % % % %     corrAngCorr(a) = mean(mTable.Correct(corrAngle2 == unAng(a)));
        % % % % % %
        % % % % % %     nTrials(a,mouseInd,condInd) = length(mTable.Correct(corrAngle2 == unAng(a)));
        % % % % % %
        % % % % % %     averageDifficulty(a) = mean(mTable.angDiff(corrAngle2 == unAng(a)));
        % % % % % % end
        % % % % %
        
        
        %%%%%%       ARRANGE BY ALL ANGLEs
        unAng = unique(abs([mTable.OrientRight ; mTable.OrientLeft]));
        corrAngCorr=[];
        perOrientDiff = zeros(8,10)
        for a = 1:length(unAng)
            filt1table = mTable(mTable.OrientLeft == unAng(a) | mTable.OrientRight == unAng(a),:);
            
            uniqDiff = unique(filt1table.angDiff);
            
            
            for aa = 1:length(uniqDiff)
                
                filt2table = filt1table;
                
                filt2table(filt2table.angDiff ~= uniqDiff(aa) ,:) = [];

                perOrientDiff(aa,a) = mean(filt2table.Correct);
                    
                nTrials(aa,a) = length(filt2table.Correct);    
                keyboard
               
            end
        end
        
        %%%% PLOT PER MOUSE
        % subplot(1,5,mouseInd)
        % hold on
        %
        % plot(unAng,corrAngCorr,'Color',colorz{condInd})
        % title(num2str(mice(mouseInd)))
        
        %%%% NORMALIZE PER MOUSE
%         meanMiceSubt(mouseInd,:,condInd) = corrAngCorr./mean(corrAngCorr);
%         meanMice(mouseInd,:,condInd) = corrAngCorr;
    end
    
    
    
    
end

seAngCorr = squeeze(std(meanMice,1)./sqrt(mouseInd));

figure
subplot(2,1,1)
plot(unAng,squeeze(mean(meanMice,1)))

legend(tasks)
xlabel('Orientation')
ylabel('Success')
title('Raw Correct')

subplot(2,1,2)
plot(unAng,squeeze(mean(meanMiceSubt,1)))

legend(tasks)
xlabel('Orientation')
ylabel('Success')
title('Mean p correct subtracted')

sgtitle(titlz)


