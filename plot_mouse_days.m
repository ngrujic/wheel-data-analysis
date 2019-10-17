%% set up parameters?
clear all;close all
load allmaus_dat
orientations = 0:20:180;

%% remove repeated trials
for mouse_ind = 1: length(maus_dat)
    for day_ind = 1:length(maus_dat{mouse_ind})
        
        if strcmp(maus_dat{mouse_ind}{day_ind,4}(1:9),'detection')
            badind = maus_dat{mouse_ind}{day_ind,5}(:,2) > 1 ;
            maus_dat{mouse_ind}{day_ind,5}(badind,:) = [] ;
            
        else
            badind = maus_dat{mouse_ind}{day_ind,5}(:,2) > 1 ;
            maus_dat{mouse_ind}{day_ind,5}(badind,:) = [] ;
        end
    end
end
%% mouse loop
for mouse_ind = 1: length(maus_dat)
    current_maus_means = [maus_dat{mouse_ind}{:,1}].';
    for day_ind = 1:length(maus_dat{mouse_ind})
        
        daymaus = maus_dat{mouse_ind}{day_ind,5};
        n_trials(day_ind) = length(maus_dat{mouse_ind}{day_ind,5});
        
        if strcmp(maus_dat{mouse_ind}{day_ind,4}(1:9),'detection')
            RTs(day_ind) = mean(maus_dat{mouse_ind}{day_ind,5}(:,3));
        else
            RTs(day_ind) = mean(maus_dat{mouse_ind}{day_ind,5}(:,4));
        end
        % orientation business
        for orient_ind = 1:length(orientations)-1
            %             keyboard
            
            if strcmp(maus_dat{mouse_ind}{day_ind,4}(1:9),'detection')
                daymaus_orient = find(daymaus(:,1) >orientations(orient_ind) & daymaus(:,1) <orientations(orient_ind+1));
                daymaus_or_means(orient_ind) = mean(daymaus(daymaus_orient,4));
                
            else
                
%                 daymaus_or_means(orient_ind) = mean(daymaus(daymaus_orient,5));
            end
        end
        maus_or_means(day_ind,:) = daymaus_or_means;
        
        
        clear daymause_or_means
    end
    mean_maus_or = nanmean(maus_or_means,1);
    clear maus_or_means
    
    figure; subplot(3,1,1)
    yyaxis left
    plot(1:length(current_maus_means),current_maus_means,'bx:'); lsline
    title(maus_dat{mouse_ind}{end,3})
    ylim([0,1]); ylabel('Percent Success')
    hold on;    yyaxis right
    plot(1:length(n_trials),n_trials,'rx:'); lsline
    ylabel('N Trials')
    
    subplot(3,1,2)
    yyaxis left
    plot(1:length(current_maus_means),current_maus_means,'bx:'); lsline
    title(maus_dat{mouse_ind}{end,3})
    ylim([0,1]); ylabel('Percent Success')
    hold on;    yyaxis right
    plot(1:length(RTs),RTs,'rx:'); lsline
    xlabel('Day of Training')
    ylabel('RT (s)'); ylim([-1 20])
    
    
    subplot(3,1,3)
    bar(mean_maus_or)
    xticklabels({'0-10','20-30','40-50','60-70','80-90','100-110','120-130','140-150','160-170'})
    ylim([0 1])
    clear n_trials mean_maus_or RTs
end

