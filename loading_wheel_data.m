%% Analyzing wheel detection task data
%% Localizing the data directories
code_path = 'C:\Users\ngrujic\Documents\Github\wheel-data-analysis';
data_path = 'P:\Nik\Wheel setup\data\wheel data\detection\setups124'; % folder with all of the M### mouse folders
cd(data_path)
mouse_dir = dir(data_path);
mouse_dir = mouse_dir(3:end); % here are all of the mouse folders we want to access them one by one

%% Load in data
data_trials = cell(length(mouse_dir),1);

for mouse_ind = 1:length(mouse_dir)
    % looping through mice
    current_dir = dir([data_path,'\', mouse_dir(mouse_ind).name]);
    isdir = [current_dir.isdir].';
    current_dir = current_dir(find(isdir));
    day_dir = current_dir(3:end);
    cd([data_path,'\',mouse_dir(mouse_ind).name])
    mouse_trials = cell(length(day_dir),1);
    
    for day_ind = 1:length(day_dir)
        % looping through days
        cd([data_path,'\',mouse_dir(mouse_ind).name,'\',day_dir(day_ind).name])
        session_dir = dir;
        session_dir(1:2) = [];
        flag = 0;
        day_trials = [];
        for session_ind = 1:length(session_dir)
            % looping through sessions in one day
            cd([data_path,'\',mouse_dir(mouse_ind).name,'\',day_dir(day_ind).name,'\',session_dir(session_ind).name])
            trials_dir = dir('*Block*.mat');
            
            if ~isempty(trials_dir) % check that there is actually data in the folder (some are empty due to errors)
                load(trials_dir.name)
                % Choice world vs advanced world.
                if isfield(block,'trial') && isfield(block.trial, 'feedbackType')
                    
                    
                    trial_conditions = struct('condition', {block.trial(1:end).condition},'feedback', {block.trial(1:end).feedbackType});
                    
                    
                    if length(trial_conditions)>20
                        trials_session = [];
                        for trial_ind = 1:length(trial_conditions)
                            % gotta loop through trials
                            trials_session(trial_ind,1) = trial_conditions(trial_ind).condition.targetOrientation;
                            trials_session(trial_ind,2) = trial_conditions(trial_ind).condition.repeatNum;
                            trials_session(trial_ind,3) = find(trial_conditions(trial_ind).condition.visCueContrast==1);
                            if ~isempty(trial_conditions(trial_ind).feedback)
                                trials_session(trial_ind,4) = trial_conditions(trial_ind).feedback ==1;
                            else
                                trials_session(trial_ind,4) = 0;
                                
                            end
                        end
                        flag = flag+1;
                        
                        day_trials{flag,1} = trials_session;
                        day_trials{flag,2} = day_dir(day_ind).name;
                        %                         clear trials_session
                    end
                    
                elseif isfield(block,'events') && isfield(block.events, 'feedbackValues')
                    
                    if size(block.paramsValues,2)>20
                        trials_session = [];
                        for trial_ind = 1:size(block.events.feedbackValues,2)
                            % gotta loop through trials
                            trials_session(trial_ind,1) = block.paramsValues(trial_ind).stimulusOrientation;
                            trials_session(trial_ind,2) = block.events.repeatNumValues(trial_ind);
                            trials_session(trial_ind,3) = find(block.paramsValues(trial_ind).stimulusContrast==1);
                            trials_session(trial_ind,4) = double(block.events.feedbackValues(trial_ind));
                            
                        end
                        flag = flag+1;
                        
                        day_trials{flag,1} = trials_session;
                        day_trials{flag,2} = day_dir(day_ind).name;
                        %                         clear trials_session
                    end
                end
                
            end
            if exist('day_trials')
                mouse_trials{day_ind} = day_trials;
                %             clear day_trials
            end
        end
        if exist('mouse_trials')
            data_trials{mouse_ind,1} = mouse_trials; % the final matrix with all beh data
            data_trials{mouse_ind,2} = mouse_dir(mouse_ind).name;
            %         clear mouse_trials
        end
    end
end
    %% Save
    cd(code_path)
    save data_trials data_trials
