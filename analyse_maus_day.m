function [delete] = analyse_maus_day(data_file);
% analysing a mouse one day of trials
% needs path of the exact mouse and day obviously

% cd(mouse_day_path)
% file = dir('*Block*');

load(data_file.name)
if length(block.trial) > 20
    
    for trial_ind = 1:length(block.trial)-1
        
        orientations(trial_ind,1) = block.trial(trial_ind).condition.targetOrientation;
        repeatnums(trial_ind,1) = block.trial(trial_ind).condition.repeatNum;
        reaction_time(trial_ind,1) = block.trial(trial_ind).responseMadeTime - block.trial(trial_ind).interactiveStartedTime;
        feedback(trial_ind,1) = double(block.trial(trial_ind).feedbackType ==1);
       [aaa, correct_side(trial_ind,1)] = max(block.trial(trial_ind).condition.visCueContrast);
        contrasts(trial_ind,:) = block.trial(trial_ind).condition.visCueContrast;
    end
    
    mouse_data = [orientations,repeatnums,reaction_time,feedback,correct_side,contrasts];
    day = data_file.name(1:10);
    mouse = data_file.name(find(data_file.name=='M'):find(data_file.name=='M')+3);
    exptype = 'detection (chW)';
    save mouse_data mouse_data day mouse exptype
    delete = 0;
else
    delete = 1;
end


end