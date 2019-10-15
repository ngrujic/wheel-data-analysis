%% Localizing the data directories
code_path = 'C:\Users\ngrujic\Documents\Github\wheel-data-analysis';
data_path = 'P:\Nik\Wheel setup\data\wheel data'; % folder with all of the M### mouse folders
cd(data_path)
mouse_dir = dir(data_path);
mouse_dir = mouse_dir(3:end); % here are all of the mouse folders we want to access them one by one

for mouse_ind = 1:length(mouse_dir)
    cd([mouse_dir(mouse_ind).folder,'\',mouse_dir(mouse_ind).name])
    day_dir = dir;day_dir = day_dir(3:end);day_dir = day_dir([day_dir.isdir].');
    
    for day_ind = 1:length(day_dir)
        cd([day_dir(day_ind).folder,'\',day_dir(day_ind).name])
        session_dir = dir; session_dir = session_dir(3:end);session_dir = session_dir([session_dir.isdir].');
        
        for session_ind = 1:length(session_dir)
            cd([session_dir(session_ind).folder,'\',session_dir(session_ind).name])
            param_file = dir('*parameters*');
            data_file = dir('*Block*');
            processed_file = dir('*mouse_data*');
            
            if isempty(processed_file)
                if ~isempty(data_file)
                    load(data_file.name);
                    load(param_file.name);
                    if strcmp(parameters.type,'ChoiceWorld')
                        delete = analyse_maus_day(data_file);
                    elseif strcmp(parameters.defFunction(end-20:end-2),'advancedChoiceWorld')
                        delete = analyse_maus_day_advChW(data_file);
                    elseif strcmp(parameters.defFunction(end-20:end-2),'discriminationWorld')
                        delete = analyse_maus_day_discWorld(data_file);
                    end
                    
                else delete = 1;
                end
                if delete == 1;
                    cd(session_dir(session_ind).folder);
                    rmdir([session_dir(session_ind).folder,'\',session_dir(session_ind).name], 's');
                    session_ind = session_ind-1;
                end
            end
        end
    end
end