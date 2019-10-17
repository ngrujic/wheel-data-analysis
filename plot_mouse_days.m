%% set up parameters?
clear all;close all
load allmaus_dat
orientations = 0:20:180;
remove_number = 13;
%% remove repeated trials
maus_dat(remove_number) = [];
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
close all
dayz = 1;
for mouse_ind = 1: length(maus_dat)
    current_maus_means = [maus_dat{mouse_ind}{dayz+1:end,1}].';
    for day_ind = dayz+1:length(maus_dat{mouse_ind})
        
        daymaus = maus_dat{mouse_ind}{day_ind,5};
        n_trials(day_ind-dayz) = length(maus_dat{mouse_ind}{day_ind,5});
        
        if strcmp(maus_dat{mouse_ind}{day_ind,4}(1:9),'detection')
            RTs(day_ind-dayz) = mean(maus_dat{mouse_ind}{day_ind,5}(:,3));
        else
            RTs(day_ind-dayz) = mean(maus_dat{mouse_ind}{day_ind,5}(:,4));
        end
        % orientation business
        for orient_ind = 1:length(orientations)-1
            %             keyboard
            
            if strcmp(maus_dat{mouse_ind}{day_ind,4}(1:9),'detection')
                daymaus_orient = find(daymaus(:,1) >orientations(orient_ind) & daymaus(:,1) <orientations(orient_ind+1));
                daymaus_or_means(orient_ind) = mean(daymaus(daymaus_orient,4));
                %                 daymaus_or_means_upper(orient_ind,:) = mean(daymaus(daymaus_orient,4))+std(daymaus(daymaus_orient,4));
                %                 daymaus_or_means_upper(orient_ind,:) = mean(daymaus(daymaus_orient,4))+std(daymaus(daymaus_orient,4));
                RTs_or_means(orient_ind) = mean(daymaus(daymaus_orient,3));
                 n_trials_ors(day_ind-dayz,orient_ind) = length(daymaus_orient);
            else
                RTs_or_means(orient_ind)  = NaN;
                daymaus_or_means(orient_ind) = NaN;
                n_trials_ors(day_ind-dayz,orient_ind) = NaN;
            end
        end
        maus_or_means(day_ind-dayz,:) = daymaus_or_means;
        maus_orRT_means(day_ind-dayz,:) = RTs_or_means;
        clear daymaus_or_means RTs_or_means
    end
    %     keyboard
    mean_maus_or = nanmean(maus_or_means,1);
    %     mean_maus_or_2SD(1,:) = mean_maus_or + 2.* nanstd(maus_or_means,[],1);
    %     mean_maus_or_2SD(2,:) = mean_maus_or - 2.* nanstd(maus_or_means,[],1);
    sum_n_trials_ors = sum(n_trials_ors,1);
    mean_maus_orRT = nanmean(maus_orRT_means,1);
    clear maus_or_means
    
    figure; subplot(4,1,1)
    yyaxis left
    plot(1:length(current_maus_means),current_maus_means,'bx:'); lsline
    title(maus_dat{mouse_ind}{end,3})
    ylim([0,1]); ylabel('Percent Success')
    hold on;    yyaxis right
    plot(1:length(n_trials),n_trials,'rx:'); lsline
    ylabel('N Trials')
    
    subplot(4,1,2)
    yyaxis left
    plot(1:length(current_maus_means),current_maus_means,'bx:'); lsline
    title(maus_dat{mouse_ind}{end,3})
    ylim([0,1]); ylabel('Percent Success')
    hold on;    yyaxis right
    plot(1:length(RTs),RTs,'rx:'); lsline
    xlabel('Day of Training')
    ylabel('RT (s)'); ylim([-1 20])
    
    
    subplot(4,1,3)
    yyaxis left
    bar((1:length(mean_maus_or))+0.2,mean_maus_or,0.3)
    ylim([0 1]); ylabel('Percent Success')
    yyaxis right
    xlim([0.1 length(mean_maus_orRT)+0.9])
    %     keyboard
    bar((1:length(mean_maus_orRT)) - 0.2, mean_maus_orRT,0.18)
    xticklabels({'0-10','20-30','40-50','60-70','80-90','100-110','120-130','140-150','160-170'})
    ylabel('RT (s)'); ylim([0 20])
    xlim([0.1 length(mean_maus_orRT)+0.9])
    
      subplot(4,1,4)
    bar((1:length(sum_n_trials_ors)), sum_n_trials_ors)
    xticklabels({'0-10','20-30','40-50','60-70','80-90','100-110','120-130','140-150','160-170'})
    ylabel('Number of trials'); 
    
    clear n_trials mean_maus_or mean_maus_orRT RTs n_trials_ors
end

