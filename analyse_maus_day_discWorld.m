function [delete] = analyse_maus_day_discWorld(data_file);
% analysing a mouse one day of trials
% needs path of the exact mouse and day obviously
%
% cd(mouse_day_path)
% file = dir('*Block*');

load(data_file.name)
if length(block.paramsValues) > 20
    
    for trial_ind = 1:length(block.paramsValues)-1
        
        orientations(trial_ind,:) = block.paramsValues(trial_ind).stimulusOrientation;
        repeatnums(trial_ind,1) = block.events.repeatNumValues(trial_ind);
        reaction_time(trial_ind,1) =  block.events.responseTimes(trial_ind) - block.events.stimulusOnTimes(trial_ind) - block.paramsValues(1).interactiveDelay;
        feedback(trial_ind,1) = double(block.events.feedbackValues(trial_ind));
        correct_side(trial_ind,1) = find(abs(block.paramsValues(trial_ind).stimulusOrientation) == min(abs(block.paramsValues(trial_ind).stimulusOrientation)));
        contrasts(trial_ind,:) = block.paramsValues(trial_ind).stimulusContrast;
    end
    
    mouse_data = [orientations,repeatnums,reaction_time,feedback,correct_side,contrasts];
    day = data_file.name(1:10);
    mouse = data_file.name(find(data_file.name=='M'):find(data_file.name=='M')+3);
    exptype = 'discrimination';
    
    save mouse_data mouse_data day mouse exptype
    delete = 0;
else
    delete = 1;
end


end