% Load the data for the correct mouse
clear all
mouse = 148;
mov_wind_size = 100;

load(strcat('all_sessions_M',num2str(mouse),'.mat'))

%% Combine all the correct incorrect into one long vector
N = length(block_sessions);

% Look at x last sessions... if want all trials then do x = N
x =N;

X = N+1-x;
session_markers = [];session_date = [];
all_trials_success = [];
all_trials_side = [];
flag = 1;
for i = X:N
    temp_trials = (block_sessions{1, i}{13, 1}.feedbackValues);
    
    % accuracy on all trials
    all_trials_success = [all_trials_success,temp_trials];
    
    if i~=N && mean(block_sessions{1, i}{6, 1}(1:6) ~= block_sessions{1, i+1}{6, 1}(1:6))
        session_markers(flag) = length(all_trials_success); % markers for end of each session
        session_dates{flag}= block_sessions{1, i+1}{6, 1}(1:6);
        flag = flag+1;
    end
    % extracting the side of the stimulus
    try
        for ii = 1:length(temp_trials)
            side(ii) =  block_sessions{1, i}{13, 1}.contrastValues(ii);
        end
    catch
        for ii = 1:length(temp_trials)
            side(ii) =  block_sessions{1, i}{14, 1}(ii).stimulusOrientation(1)==0;
        end
    end
    all_trials_side = [all_trials_side,side];
    side = [];
end

%% Raw means every 10 trials
flag=0;
for i = 10:10:length(all_trials_success)
    flag = flag+1;
    mean_trace(flag) = mean(all_trials_success(i-9:i));
end
figure(mouse);subplot(4,1,1);line(1:length(mean_trace),mean_trace);ylim([0 1]);title('Mean of every 10 trials')
%% Moving mean and plot of all trials

all_trials_movmean = movmean(all_trials_success,mov_wind_size);
best_fit = polyfit(1:length(all_trials_success),all_trials_movmean,1);
best_values = polyval(best_fit,1:length(all_trials_movmean));

subplot(4,1,2);
plot(1:length(all_trials_success), all_trials_movmean)
for i = 1:length(session_markers)
    hold on
    line([session_markers(i),session_markers(i)],[0,1],'Color','r')
end
xticks(session_markers);
if ~isempty(session_dates)
xticklabels(session_dates)
end
hold on
plot(1:length(all_trials_movmean), best_values,'g');ylim([0 1]);hold on; line([0 length(all_trials_movmean)],[0.5 0.5])
title(['Moving mean of successes with a line of best fit',' - moving window size = ',num2str(mov_wind_size)])
%% Separating the plots by side of stimulus

left_ind = find(all_trials_side == -1);
right_ind = find(all_trials_side == 1);
left_success = all_trials_success(left_ind);
right_success = all_trials_success(right_ind);

left_movmean = movmean(left_success, mov_wind_size) ;
right_movmean = movmean(right_success,mov_wind_size);

%plotting the left side and right side stim moving means
subplot(4,1,3);
plot(1:length(left_movmean),left_movmean,'b');ylim([0 1]);title('Left (blue) vs Right side trials accuracy')
hold on
plot(1:length(right_movmean),right_movmean,'r');ylim([0 1]);
subplot(4,1,4);
if length(right_movmean)>length(left_movmean)
    plot(1:length(left_movmean),right_movmean(1:length(left_movmean))-left_movmean)
else
    plot(1:length(right_movmean),right_movmean-left_movmean(1:length(right_movmean)))
end

title('Right side minus left side accuracy')


%% Orientations 
N = length(block_sessions);
flag = 1;
X = 52;
for i = 1:N
    
    session_success = block_sessions{1, i}{13, 1}.feedbackValues;

    orients = 0:10:90;
    
    for ii = 1:length(orients)
    stimulusOrientation = [block_sessions{1, i}{14, 1}.stimulusOrientation].'  ;  
        
    orientation_ind = find(stimulusOrientation == orients(ii));
    
    orientation_correct(ii,flag) = sum(session_success(orientation_ind));
    orientation_ntrials(ii,flag) = length(session_success(orientation_ind));
    
    end
   
    flag = flag+1;
end

allSessionsCorrect = sum(orientation_correct,2);
allSessionsNtrials = sum(orientation_ntrials,2);

allSessionsSuccess = (allSessionsCorrect./allSessionsNtrials)*100;
figure
bar(orients,allSessionsSuccess)



