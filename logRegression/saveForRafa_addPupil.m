%% find all files
clear; close all;
data_path = uigetdir; % folder with all of the M### mouse folders
cd(data_path)
mouse_folders = dir(data_path);
mouse_folders = mouse_folders(3:end);

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

PupilBaseline = [];
PupilQueiscence = [];


for mouse_ind = 1:length(mouse_folders)
    cd([mouse_folders(mouse_ind).folder,'/',mouse_folders(mouse_ind).name])
    % get names of all data.mat files
    mouse_files = dir;
    mouse_files = mouse_files(~[mouse_files.isdir]);
    [~,idx] = sort([mouse_files.datenum]);
    mouse_files=mouse_files(idx);
    %
    %     % remove all png files
    %     filesToDelete = [];
    %     for filenumber = 1:length(mouse_files)
    %         if strcmp(mouse_files(filenumber).name(end-3:end), '.mat') == 1
    %         else
    %             filesToDelete = [filesToDelete, filenumber];
    %         end
    %     end
    %     mouse_files(filesToDelete) = [];
    %
    %% Collect Variables
    for file_ind = 1:length(mouse_files)
        load([mouse_files(file_ind).folder,'/',mouse_files(file_ind).name]);
        
        
        %Make variables same length
        trialLength = min([length(correct), length(correctResponse), length(response), length(orientationL), length(orientationR), length(trialRepeated), length(RT)]);
        correct = correct(1:trialLength);
        correctResponse = correctResponse(1:trialLength);
        response = response(1:trialLength);
        orientationL = orientationL(1:trialLength);
        if exist('contrastL','var')==1 && length(contrastL)==trialLength
            contrastL = contrastL(1:trialLength);
        else
            contrastL = ones(1,trialLength);
        end
        orientationR = orientationR(1:trialLength);
        if exist('contrastR','var')==1 && length(contrastR)==trialLength
            contrastR = contrastR(1:trialLength);
        else
            contrastR = ones(1,trialLength);
        end
        trialRepeated = trialRepeated(1:trialLength);
        RT = RT(1:trialLength);
        DateName = [];
        
        DateName = repmat(file_ind,trialLength,1);
        MouseNumber = repmat(mouse_folders(mouse_ind).name(2:4), trialLength,1);
        
        %Variables to collect if accuracy is over 55 percent
        if mean(correct) > 0.55
            Correct = [Correct; correct'];
            CorrectResponse = [CorrectResponse; correctResponse'];
            Response = [Response; response'];
            OrientLeft = [OrientLeft; orientationL'];
            ContrastLeft = [ContrastLeft; contrastL'];
            OrientRight = [OrientRight; orientationR'];
            ContrastRight = [ContrastRight; contrastR'];
            RepeatOn = [RepeatOn; ones(length(correct), 1)*repeatIncorrect];
            TrialRepeated = [TrialRepeated;trialRepeated'];
            ReactionTime = [ReactionTime; RT'];
            Date = [Date; DateName];
            MouseNr = [MouseNr; MouseNumber];
        end
        
    end
    
end
% s
% % remove all RT > 6 sec
% trialsToDelete = [];
% for trial = 1:length(Correct)
%     if ReactionTime(trial) < 6
%     else
%         trialsToDelete = [trialsToDelete, trial];
%     end
% end

cd ..
AllMouseData = table(Correct, CorrectResponse, Response, OrientLeft, OrientRight, ContrastLeft, ContrastRight, RepeatOn, TrialRepeated, ReactionTime, Date, MouseNr);
AllMouseData(trialsToDelete,:) = [];
writetable(AllMouseData)

%clearvars -except Correct CorrectResponse Response OrientLeft OrientRight RepeatOn TrialRepeated ReactionTime FileName mouse_files data_path file_ind
% clearvars -except AllMiceCorrect AllMiceOrientLeft AllMiceOrientRight AllMiceRT data_path
% AllMiceData = [AllMiceCorrect; AllMiceRT; AllMiceOrientLeft; AllMiceOrientRight];
% cd(data_path)