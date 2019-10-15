%% Localizing the data directories
clear all;close all
load('data_path.mat')
data_path = data_path.data_path;
mouse_dir = dir(data_path);
mouse_dir = mouse_dir(3:end); % here are all of the mouse folders we want to access them one by one
mouse_dir = mouse_dir([mouse_dir.isdir].');

for mouse_ind = 1:length(mouse_dir)
    cd([mouse_dir(mouse_ind).folder,'\',mouse_dir(mouse_ind).name])
    day_dir = dir;day_dir = day_dir(3:end);day_dir = day_dir([day_dir.isdir].');
    flag = 0;
    for day_ind = 1:length(day_dir)
        cd([day_dir(day_ind).folder,'\',day_dir(day_ind).name])
        session_dir = dir; session_dir = session_dir(3:end);session_dir = session_dir([session_dir.isdir].');
        
        for session_ind = 1:length(session_dir)
            cd([session_dir(session_ind).folder,'\',session_dir(session_ind).name])
            processed_file = dir('*mouse_data*');
            
            
            load(processed_file.name)
            
            flag = flag+1;
            if strcmp(exptype, 'discrimination')
                temp{flag,1} = mean(mouse_data(find(mouse_data(:,3)==1),5));
            else
                temp{flag,1} = mean(mouse_data(find(mouse_data(:,2)==1),4));
            end
                temp{flag,2} = day;
                temp{flag,3} = mouse;
                temp{flag,4} = exptype;
                temp{flag,5} = mouse_data;
            
            
        end
    end
    maus_dat{mouse_ind} = temp;
    clear temp
end

cd(data_path)
save allmaus_dat maus_dat