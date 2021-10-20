%% script for checking the onset output

clear all
% get dir of the folder you wish
conditionDir = uigetdir;
cd(conditionDir);
condition = conditionDir(find(conditionDir == '\',1,'last')+1:end);
dayCell = dir('*.csv');

% parameters
recFs = 60;
baselineFromTo = [-0.5 -0.1]*recFs;
base = 0.75*recFs;
post = 10*recFs;
blinkLikelihoodThresh = 0.99;

%Variables to collect
Correct = [];
CorrectResponse = [];
Response = [];
OrientLeft = [];
ContrastLeft = [];
OrientRight = [];
ContrastRight = [];
RepeatOn = [];
TrialRepeated = [];
ReactionTime = [];
Date = [];
MouseNr = [];
DateSerial = [];
BaselinePupil = [];
Choice1B = [];
mouseTemp = [];
mouseNr = [];

totalLossOfBlinkTrials=0;
align_to_rew = 0;
i=0;i2=0; i3 = 0;everydayCount = 0;
%%
for dayInd = 1:length(dayCell)
    dayInd
    cd(conditionDir);
    
    currDay = dayCell(dayInd).name;
    
    if mouseNr ~= str2num(currDay(1:3));
        everydayCount = 1;
    else
        everydayCount = everydayCount+1;
    end
    % convert dates etc to match up files
    mouseNr = str2num(currDay(1:3));
    dayDate = datenum(currDay(5:12),'mmddyyyy');
    matDate = datestr(dayDate,'dd-mmm-yyyy');
    txtDate = datestr(dayDate,'mmddyyyy');
    csvDate = txtDate;
    cd(['P:\Nik\Wheel setup\WheelData\M', num2str(mouseNr)]);
    matFile = dir(['*' matDate '*.mat']);
    try
        load(matFile.name,'correct','RT','ITI','contrastR','contrastL','rewardMs','correctResponse','orientationL','orientationR',...
            'trialRepeated','repeatIncorrect','response');
        angleDiff = abs(abs(orientationL) - abs(orientationR));
        
        % load correct txt and mat and csv
        cd(conditionDir);
        txtFile = dir([num2str(mouseNr),'-',txtDate,'*.txt']);
        thresholdedVals = load(txtFile.name);
        
        % Get min iti
        betweenOnsetsFrame = min(ITI(1:length(correct)-1));
        min_onset_dur = 50;
        
        close all
        [xxx,onsetsDat] = getanalogsignalonsets_pupil(thresholdedVals,0.5,60,betweenOnsetsFrame,0,0,0,min_onset_dur);
        csvFile = dir(['*', num2str(mouseNr) '-',csvDate,'*.csv']);
        
        %%
        betweenOnsetst = RT + ITI(1:length(correct))./60 + 1;
        betweenOnsets = betweenOnsetst(1:end-1);
        onsetDiff = diff(onsetsDat)./60;
%         onsetsDat = onsetsDat(1:length(correct));
        
        try
            figure(2)
            subplot(2,1,1)
            hold off
            plot(betweenOnsets(1:length(onsetDiff)))
            hold on
            plot(onsetDiff,'r')
            title([matDate,'  ',num2str(mouseNr)])
            subplot(2,1,2)
            hold off
            plot(betweenOnsets(1:length(onsetDiff)) - onsetDiff)
        catch
            figure(2)
            subplot(2,1,1)
            hold off
            plot(betweenOnsets(1:20))
            hold on
            plot(onsetDiff(1:20),'r')
            title([matDate, ' onsets difference = ' num2str(length(correct) - length(onsetsDat))])
            subplot(2,1,2)
            hold off
            plot(betweenOnsets(end-20:end))
            hold on
            plot(onsetDiff(end-20:end))
        end
        %%
        keyboard
        % little helpers for insertion or removal
        
        if 0
            insertVal = 340
            insertAfter = 1
            onsetsDat = [onsetsDat(1:insertAfter) insertVal onsetsDat(insertAfter+1:end)]
            onsetsDat = onsetsDat(1:length(correct));
        end
        
        
        if 0
            cutTo = 597
            onsetsDat = onsetsDat(1:cutTo);
        end
        
        if 0
            remove = 2
            onsetsDat(remove) = [];
        end
        
        if 0
            figure(3)
            subplot(2,1,1)
            plot(betweenOnsets(1:length(betweenOnsets)))
            hold on
            plot(onsetDiff,'r')
            title([matDate, 'same length vectors'])
            subplot(2,1,2)
            hold off
            plot(betweenOnsets(1:length(betweenOnsets)) - onsetDiff(1:length(betweenOnsets)))
        end
        
        %%
        pause(0.5)
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        
        while ~ keyIsDown
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
            pause(0.05)
            
        end
        pressed = find(keyCode);
        if pressed == 71
            % FOR MANUAL CHECKING LAST 20 POINTS
            i2 = i2+1;
            fprintf('\n good \n')
            csvDat = csvread(csvFile.name,3);
            [eyeCentre, pupilSize,eyesLikelihood,licks,eyePointDistances] = getPupilSizePositionCSV_reflectionModelDebug(csvDat);
            dayExp(i2).date = matDate;
            dayExp(i2).expData = [correct', correctResponse(1:length(correct))', response', orientationL(1:length(correct))', orientationR(1:length(correct))' ...
                contrastL(1:length(correct))' contrastR(1:length(correct))' repmat(repeatIncorrect,length(correct),1)...
                trialRepeated(1:length(correct))' RT' angleDiff(1:length(correct))' ...
                repmat(mouseNr,length(correct),1)  ];
            dayExp(i2).expData =  [onsetsDat' dayExp(i2).expData(1:length(onsetsDat),:)];
            %         dayExp(i2).dlcData = [eyeCentre pupilSize licks eyesLikelihood ];
            dayExp(i2).dlcData = [eyeCentre pupilSize eyesLikelihood ];
            
            dayExp(i2).allEyes = eyePointDistances;
            dayExp(i2).expDatInfo = 'expData columns: onsetFrame, correct, angleDifference, RT, sum contrast, rewardMs';
            dayExp(i2).dlcDatInfo = ' dlcData columns: 1,2= eyeposition x,y ,3= pupil size, 4 =lick, eye likelihood onwards';
            
            close all
            % if there is a mismatch of onsets or something then assign day to badDays
        else
            fprintf(['\n' matDate ' is not good'])
            i = i+1;
            badDays{i} = matDate;
        end
        if pressed == 71
            %%%%%%%%% ARRANGING INTO TRIALS AND REMOVING BLINK ETC
            dateTempSer = datenum(dayExp(i2).date,'dd-mmm-yyyy');
            dayExp(i2).expData(1,:) = [];
            dayExp(i2).expData(end,:) = [];
            dayExp(i2).dlcData(1,:) = [];
            dayExp(i2).dlcData(end,:) = [];
            
            mouseTemp =  dayExp(i2).expData(1,13);
            
            % get current day DLC data
            dayDLC = dayExp(i2).dlcData;
            expDat = dayExp(i2).expData;
            %     dayAll = dayExp(dayInd).allEyes;
            
            
            
            % align to reward vs to onset
            if ~align_to_rew
                onsets = expDat(:,1);
            else
                onsets = expDat(:,1)+30+expDat(:,4)*60;
            end
            
            %%%%%%%%%%%%%%% 20hz lowpass and Z SCORING IS HERE %%%%%%%%%%%
            % first cut all DLC variables to last onset and filter
            dayDLC = dayDLC(1:onsets(end)+60+post+expDat(:,4)*60,:);
            dayDLC(:,3) = zscore(lowpass(dayDLC(:,3),20,60));
            %             dayDLC(:,3) = rescale(dayDLC(:,3),-1,1);
            
            
            % loop over onsets to extract each trial
            basepup=[]; allPupSizes = []; goodTrialInd = 0; blinkTrials = [];dlcData = [];pupilSize = []; xPos = []; yPos = []; lick = []; BaselinePupilTemp=[];pupilSizeConcat=[];
            for onInd = 1:length(onsets)
                currentOnset = onsets(onInd);
                
                % see if any points are badly, tracked or not present due to blink
                likelihoodTrials = dayDLC(currentOnset - base:currentOnset + post,4:end);
                
                % find outliers
                outlierTest = filloutliers(dayDLC(currentOnset - base:currentOnset + post,3),'previous');
                
                % only fill trials matrix with good trials
                if min(likelihoodTrials(:)) > blinkLikelihoodThresh && sum(isnan(outlierTest))==0
                    goodTrialInd = goodTrialInd+1;
                    basepup(goodTrialInd,:) = filloutliers(dayDLC(currentOnset - base:currentOnset + post,3),'previous');
                    
                    pupilSize(goodTrialInd,:) = dayDLC(currentOnset - base:currentOnset + post,3);
                    xPos(goodTrialInd,:) = dayDLC(currentOnset - base:currentOnset + post,1);
                    yPos(goodTrialInd,:) = dayDLC(currentOnset - base:currentOnset + post,2);
                    lick(goodTrialInd,:) = dayDLC(currentOnset - base:currentOnset + post,4);
                    BaselinePupilTemp(goodTrialInd) = mean(dayDLC(currentOnset + baselineFromTo(1):currentOnset + baselineFromTo(2),3));
                    
                    %             allPupSizes(:,:,goodTrialInd) = dayAll(currentOnset - base:currentOnset + post,:);
                    %             pupilSizeConcat = [pupilSizeConcat pupilSize(goodTrialInd,:)];
                else
                    blinkTrials = [blinkTrials onInd];
                end
            end
            
            % remove blink trials also from expDat
            expDat(blinkTrials,:) = [];
            
            % ZSCORING IS HERE
            %         pupTemp = pupilSize';
            %         pupilSizeZ = reshape(zscore(pupTemp(:)),size(pupTemp,1),size(pupTemp,2))'
            
            % rescale as well
            
            %             figure(400)
            %             plot(basepup')
            %             keyboard
            %             close all
            %             pause(0.3)
            %             pupilSizeZ = rescale(basepup,-1,1);
            pupilSizeZ = basepup;
            
            figure(3)
            subplot(4,1,1)
            title('imagesc')
            imagesc(pupilSizeZ);hold on; xline(0.75*60,'r'); caxis([-1 1]); xlim([0 300]);
            subplot(4,1,2)
            hold off
            
            plot(mean(pupilSizeZ(expDat(:,2)==1,:),1),'g');
            hold on; xline(0.75*60,'k');xlim([0,300])
            plot(mean(pupilSizeZ(expDat(:,2)==0,:),1),'r')
            
            title('mean')
            subplot(4,1,3)
            hold off
            
            plot(median(pupilSizeZ(expDat(:,2)==1,:),1),'g');
            hold on; xline(0.75*60,'k');xlim([0,300])
            plot(median(pupilSizeZ(expDat(:,2)==0,:),1),'r')
            
            title('median')
            subplot(4,1,4)
            plot((pupilSizeZ(1:end,:)'));xlim([0,300]);xline(0.75*60,'r');
            pause(0.05)
            
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
            while ~ keyIsDown
                [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
                pause(0.05)
                
            end
            pressed = find(keyCode);
            
            
            if pressed == 71
                i3 = i3+1;
                dlcData.pupilSize = pupilSizeZ;
                dlcData.xPos = xPos;
                dlcData.yPos = yPos;
                dlcData.lick = lick;
                dlcData.BaselinePupil = BaselinePupilTemp;
                %     close all
                
                
                
                %     subplot(4,1,3)
                %     imagesc(lick);hold on; xline(0.75*60,'r')
                %       subplot(4,1,4)
                %     plot(mean(lick,1));hold on; xline(0.75*60,'r');xlim([0,226])
                %%%%%% more debugging bullshit
                %         meanpup = squeeze(mean(allPupSizes,3));
                
                % add choice of trial before to the expDat
                expDat(:,14) = sign(rand-0.5);
                expDat(2:end,14) = expDat(1:end-1,4);
                
                
                
                DateSerialN = repmat(dateTempSer,size(expDat,1),1);
                
                dayExpTrials(i3).dlcData = [];
                dayExpTrials(i3).expData = expDat;
                dayExpTrials(i3).dlcData = dlcData;
                dayExpTrials(i3).blinkTrials = blinkTrials;
                dayExpTrials(i3).datainfo = 'expData columns: onsetFrame, correct, angleDifference, RT, contrast and rew size';
                dayExpTrials(i3).mouseNr = mouseNr;
                dayExpTrials(i3).DateSerialN = DateSerialN(1,1);

                Correct = [Correct; expDat(:,2)];
                CorrectResponse = [CorrectResponse; expDat(:,3)];
                Response = [Response; expDat(:,4)];
                OrientLeft = [OrientLeft; expDat(:,5)];
                ContrastLeft = [ContrastLeft; expDat(:,6)];
                OrientRight = [OrientRight; expDat(:,7)];
                ContrastRight = [ContrastRight; expDat(:,8)];
                RepeatOn = [RepeatOn; expDat(:,9)];
                TrialRepeated = [TrialRepeated;expDat(:,10)];
                ReactionTime = [ReactionTime; expDat(:,11)];
                Choice1B = [Choice1B; expDat(:,14)];
                
                Date = [Date; repmat(everydayCount,size(expDat,1),1)];
                MouseNr = [MouseNr; expDat(:,13)];
                
                DateSerial = [DateSerial; DateSerialN];
                BaselinePupil = [BaselinePupil; dlcData.BaselinePupil'];
                
                totalLossOfBlinkTrials = totalLossOfBlinkTrials + length(blinkTrials)
            else
                i = i+1;
                badDays{i} = matDate;
                close all
            end
        end
    catch
        i = i+1;
        badDays{i} = matDate;
    end
end
AllMouseData = table(Correct, CorrectResponse, Response, Choice1B, OrientLeft,...
    OrientRight, ContrastLeft, ContrastRight, RepeatOn, TrialRepeated, ReactionTime,...
    Date, MouseNr, BaselinePupil, DateSerial);

% IF SAVING FOR RAFA
writetable(AllMouseData,[condition,'_forRafa'])

% SAVE the extracted data
if ~align_to_rew
    save([condition, '_dataTrials'],'dayExpTrials','-v7.3')
else
    save([condition, '_dataTrialsRewAlign'],'dayExpTrials','-v7.3')
end
