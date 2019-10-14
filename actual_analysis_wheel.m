%% Load data
data_path = 'C:\Users\ngrujic\Documents\Behaviour'
cd(data_path)
load data_trials.mat
orientations = [0:10:170];
%%
day_trials = [];

for mouse_ind = 1:length(data_trials)
    mouse_order{mouse_ind} = data_trials{mouse_ind,2};
    mouse_trials = [];
    for day_ind = 1:length(data_trials{mouse_ind,1})
       
        if ~isempty(data_trials{mouse_ind,1}{day_ind,1})
            day_trials = [];
            for session_ind = 1:size(data_trials{mouse_ind,1}{day_ind,1},1)
                day_trials = [day_trials; data_trials{mouse_ind,1}{day_ind,1}{session_ind,1}];
                
            end
             mouse_trials = [mouse_trials;day_trials];
        end
       
       
    end
    if ~isempty(mouse_trials)
    all_trials{mouse_ind,1} = mouse_trials;
    end
end

%% Data successfully put into trials - finally.
win_size = 100;
all_trials_movmeans = [];
close all
for mouse_ind = 1:length(all_trials)
    non_rep_trials = find(all_trials{mouse_ind,1}(:,2)==1);
    all_trials_movmeans{mouse_ind,1} = movmean(all_trials{mouse_ind,1}(non_rep_trials,4),win_size);

    figure(mouse_ind)
    plot(all_trials_movmeans{mouse_ind,1},'bo')
lsline
title(mouse_order{1,mouse_ind})
    ylim([0 1])
end

