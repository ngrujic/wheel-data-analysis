%% script for checking the onset output

clear all
% load the correct .txt
dayCell = cell(uigetfile('.csv','MultiSelect','ON'))
i=0;i2=0;
condition = 'debugging\reflectModel';

%%
for dayInd = 1:length(dayCell)
    dayInd
    cd(['C:\worktemp\Wheel\pupilDat\',condition]);
    
    
    % convert dates etc to match up files
    currDay = dayCell{dayInd};
    mouseNr = str2num(currDay(1:3));
    dayDate = datenum(currDay(5:12),'mmddyyyy');
    matDate = datestr(dayDate,'dd-mmm-yyyy');
    txtDate = datestr(dayDate,'mmddyyyy');
    csvDate = txtDate;
    cd(['P:\Nik\Wheel setup\WheelData\M', num2str(mouseNr)]);
    matFile = dir(['*' matDate '*.mat']);
    load(matFile.name,'correct','RT','ITI','angleDiff','contrastR','contrastL','rewardMs','correctResponse','orientationL','orientationR',...
        'trialRepeated','repeatIncorrect','response');
    angleDiff = abs(abs(orientationL) - abs(orientationR));
    % load correct txt and mat and csv
    cd(['C:\worktemp\Wheel\pupilDat\',condition]);
    txtFile = dir([num2str(mouseNr),'-',txtDate,'*.txt']);
    
    
    thresholdedVals = load(txtFile.name);
    
    %  [pd_onset_seconds,pd_onset_idx] = getanalogsignalonsets_pupil
    % (inputSignal, photodiode_threshold, photodiode_sampling_freq, min_ISI_secs,saveit,savename,invert_signal)
    
    betweenOnsetsFrame = min(ITI(1:length(correct)-1));
    min_onset_dur = 50;
    %     minITI = min(betweenOnsetsFrame) ;
    close all
    [xxx,onsetsDat] = getanalogsignalonsets_pupil(thresholdedVals,0.5,60,betweenOnsetsFrame,0,0,0,min_onset_dur);
    
    
    %     test = rewardMs;
    % correct reward sizes
    %     unRew = unique(rewardMs);
    %     for a = 1:length(unRew)
    %        rewardMs(rewardMs == unRew(a)) = a;
    %     end
    % % %     test = [test ;rewardMs];
    % % %     keyboard
    
    csvFile = dir(['*', num2str(mouseNr) '-',csvDate,'*.csv']);
    % TAKE XCORR TO LOOK AT MISMATCH
    %     [r, lag] = xcorr(onsetDiff,betweenOnsets(1:end));
    %     lagShift = lag(find(r==max(r)));
    %     onsetDiff = onsetDiff(1+lagShift:length(betweenOnsets)+lagShift);
    %     onsetsDat = onsetsDat(1+lagShift:length(correct)+lagShift);
    % check whether there is matchup in onsets
    %%
    betweenOnsetst = RT + ITI(1:length(correct))./60 + 1;
    betweenOnsets = betweenOnsetst(1:end-1);
    onsetDiff = diff(onsetsDat)./60;
    try
        figure(2)
        subplot(2,1,1)
        hold off
        plot(betweenOnsets(1:length(onsetDiff)))
        hold on
        plot(onsetDiff,'r')
        title([matDate, 'same length vectors'])
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
            insertVal = 435
    insertAfter = 2
          onsetsDat = [onsetsDat(1:insertAfter) insertVal onsetsDat(insertAfter+1:end)]
          onsetsDat = onsetsDat(1:length(correct));
    end
    

    if 0 
            cutTo =225
         onsetsDat = onsetsDat(1:cutTo);
    end
    
    if 0 
    remove = 5
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
%         figure
%         plot(pupilSize)
%         keyboard
        % if there is a mismatch of onsets or something then assign day to badDays
    else
        fprintf(['\n' matDate ' is not good'])
        i = i+1;
        badDays{i} = matDate;
    end
end

save([condition, '_extractedData'],'dayExp','-v7.3')

