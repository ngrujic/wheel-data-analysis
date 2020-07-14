clear all; close all
% dates: from - to
startDate = datenum('9-Jul-2020');
currentDate = datenum('14-Jul-2020');
allDates = startDate:currentDate;

dataMarker = 'last_day_all_mice'

% list the mice?
mice = {'155' '160' '192' '123' '222'  '137' '159' '160b' '161' '144' '136' '145' '142' };

% mouse data location
mDataFolder = 'P:\Nik\Wheel setup\WheelData\' ;

% initialise flags and variables
mouseMat=[];

for mousInd = 1:length(mice)
    % initialise outer loop flags and variables
    mouseData= [];
    i1=0;
    
    % cd into mouse folder
    cd([mDataFolder, 'M', mice{mousInd}])
    
    for dayInd = 1:length(allDates)
        clear contrastL contrastR
        
        % current loop date - gotta have try in case no exp on given date
        tempDate = datestr(allDates(dayInd));
        
        ['*',tempDate,'*.mat']
        
        try
            % find exp day
            dayExp(dayInd) = dir(['wheel*',tempDate,'*.mat']);
            load(dayExp(dayInd).name)
            
            %%% IF you want only days with contrast manipulation
            %             contrastL
            if ~exist('contrastL')
                contrastL = repmat(1,1,length(correct));
                contrastR = repmat(1,1,length(correct));
                contrastTask = repmat(0,1,length(correct));
            else
                contrastTask = repmat(1,1,length(correct));
            end
            %%% IF you want only days
            if ~exist('rewardOrientation')
                rewardOrientation = repmat(0,1,length(correct));
            end
            
            %%% IF only with the fine grained contrast
%             if sum(orientationL == 20) > 0 
                
                % FILTERING THE DAY - eg if >60% total include in the analysis
%                 if perccorr >= 0
                    i1= i1+1;
                    mouseData = [mouseData; repmat(mousInd,length(correct),1) repmat(i1,length(correct),1), double(correct)' RT' correctResponse(1:length(correct))' response' repmat(repeatIncorrect,length(correct),1) trialRepeated(1:length(correct))'...
                        repmat(mousInd,length(correct),1) repmat(rewardOrientation,length(correct),1) orientationL(1:length(correct))' orientationR(1:length(correct))' contrastL(1:length(correct))' contrastR(1:length(correct))' contrastTask'];
                    %
                    i1
%                 end
%             end
            
        end
        
    end
    
    mousedatalength = length(mouseData)
    mice{mousInd}
    
    % saving in big cell and normal array mouseMat is everything combined
    allMiceData{mousInd,1} = mouseData;
    allMiceData{mousInd,2} = mice{mousInd};
    allMiceData{mousInd,3} = dayExp;
    
    mouseMat = [mouseMat; mouseData];
    clear dayExp
end

%% save variables in right folder
cd([mDataFolder, 'combinedData'])
save([dataMarker,'combinedData_',date], 'allMiceData', 'mouseMat','mice')




