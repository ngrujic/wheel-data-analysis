function [mouse_data,day] = analyse_maus_day(mouse_day_path);
% analysing a mouse one day of trials
% needs path of the exact mouse and day obviously

cd(mouse_day_path)
file = dir('*Block*');

load(file.name)

for trial_ind = 1:length(block.trial)-1
    
    orientations(trial_ind) = block.trial(trial_ind).condition.targetOrientation;
    repeatnums(trial_ind) = block.trial(trial_ind).condition.repeatNum;
    reaction_time(trial_ind) = block.trial(trial_ind).responseMadeTime - block.trial(trial_ind).interactiveStartedTime;
    feedback(trial_ind) = block.trial(trial_ind).feedbackType;
    
    
end

mouse_data = [orientations;repeatnums;reaction_time;feedback];
day = file.name(1:10);

end






