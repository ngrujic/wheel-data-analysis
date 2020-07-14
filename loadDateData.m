clear all; close all
% dates: from - to
startDate = datenum('02-Dec-2019');
currentDate = now;
allDates = startDate:currentDate;

% list the mice?
mice = [123 155 160 192 195 222];

% mouse data location
mDataFolder = 'P:\Nik\Wheel setup\WheelData\' ;

% initialise flags and variables
mouseMat=[];

for mousInd = 1:length(mice)
    % initialise outer loop flags and variables
    mouseData= [];
    i=0;

    % cd into mouse folder
    cd([mDataFolder, 'M', num2str(mice(mousInd))])
    
    for dayInd = 1:length(allDates)
        
        % current loop date - gotta have try in case no exp on given date
        tempDate = datestr(allDates(dayInd));
        
        try
            % find exp day
            dayExp(dayInd) = dir(['wheel*',tempDate,'*.mat']);
            load(dayExp(dayInd).name)
            
            % FILTERING THE DAY - eg if >60% total include in the analysis
            if perccorr >= 55
                i= i+1;
                mouseData = [ mouseData; [repmat(i,length(correct),1), double(correct)' RT' correctResponse(1:length(correct))' repmat(repeatIncorrect,length(correct),1) trialRepeated(1:length(correct))'...
                    recentPercent'  orientationL(1:length(correct))' orientationR(1:length(correct))']];
                
            end
        end
        
    end
    
    % saving in big cell and normal array mouseMat is everything combined
    allMiceData{mousInd,1} = mouseData;
    allMiceData{mousInd,2} = num2str(mice(mousInd));
    allMiceData{mousInd,3} = dayExp;

    mouseMat = [mouseMat; mouseData];
    clear dayExp
end

%% save variables in right folder
cd([mDataFolder, 'combinedData'])
save(['combinedData_',date], 'allMiceData', 'mouseMat')




