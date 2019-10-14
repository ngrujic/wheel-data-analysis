%% This code loads all the sessions for animal for each day and block and
% saves them to a desired location

clear all

data_path = 'P:\Nik\Wheel setup';

mouse = 148;
mouse_path  =strcat(data_path,'\M',num2str(mouse));
mouse_dir = dir(strcat(data_path,'\M',num2str(mouse)));
sessions = mouse_dir(3:end-2);

flag = 1;
for i = 1:length(sessions)
    
    curr_dir = dir(strcat(mouse_path,'\',sessions(i).name));
    curr_dir = curr_dir(3:end);
    
    for ii = 1:length(curr_dir)
       temp_curr_dir(ii) = str2num(curr_dir(ii).name);
    end
    temp_curr_dir = sort(temp_curr_dir);
    
    for ii = 1:length(curr_dir)
       real_curr_dir(ii).name = num2str(temp_curr_dir(ii));        
    end
    
    for bla= 1:length(real_curr_dir)
        
        cd(strcat(curr_dir(bla).folder,'\',real_curr_dir(bla).name));
        
        session_dir = dir;
        if length(session_dir) >4
            load(session_dir(3).name);
            block_sessions{flag} = struct2cell(block);
            flag = flag+1;
        end
    end
    clear temp_curr_dir real_curr_dir
end

savename = strcat('all_sessions_','M',num2str(mouse));
cd 'P:\Nik\Wheel setup\data'
save(savename,'block_sessions')