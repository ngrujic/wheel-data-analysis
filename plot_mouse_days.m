%% set up parameters?
clear all;close all
load allmaus_dat
orientations = 0:20:180;
% remove_number = [];
%% remove repeated trials
% maus_dat(remove_number) = [];
all_mice_dat = cell(1,length(maus_dat));
for mouse_ind = 1: length(maus_dat)
    for day_ind = 1:length(maus_dat{mouse_ind})
        
        %
        %         mausday = maus_dat{mouse_ind}{day_ind,5};
        %         all_mice_dat{mouse_ind} = [all_mice_dat{mouse_ind}; mausday];
        
        if strcmp(maus_dat{mouse_ind}{day_ind,4}(1:9),'detection')
%             badind = maus_dat{mouse_ind}{day_ind,5}(:,2) > 1 ;
%             maus_dat{mouse_ind}{day_ind,5}(badind,:) = [] ;
            mausday = maus_dat{mouse_ind}{day_ind,5};
            all_mice_dat{mouse_ind} = [all_mice_dat{mouse_ind}; mausday];
        else
            badind = maus_dat{mouse_ind}{day_ind,5}(:,2) > 1 ;
            maus_dat{mouse_ind}{day_ind,5}(badind,:) = [] ;
        end
    end
end
%% mouse loop
close all
dayz = 5;
from_trial = 0;
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
    end
    % orientation business HAS TO BE SPECIAL
    for orient_ind = 1:length(orientations)-1
        
        daymaus_orient = find(all_mice_dat{mouse_ind}(from_trial+1:end,1) >orientations(orient_ind)...
            & all_mice_dat{mouse_ind}(from_trial+1:end,1) <orientations(orient_ind+1));
        maus_or_means(orient_ind) =  mean(all_mice_dat{mouse_ind}(daymaus_orient+from_trial,4));
        RTs_or_means(orient_ind) = mean(all_mice_dat{mouse_ind}(daymaus_orient+from_trial,3));
        
        maus_or_STDs(orient_ind) = std(all_mice_dat{mouse_ind}(daymaus_orient+from_trial,4),[],'all');
        RTs_or_STDs(orient_ind) =  std(all_mice_dat{mouse_ind}(daymaus_orient+from_trial,3));

        n_trials_ors(orient_ind) = length(daymaus_orient);
        
    end
    
    aa= figure; subplot(4,1,1)
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
    ylim([0,1]); ylabel('Percent Success')
    hold on;    yyaxis right
    plot(1:length(RTs),RTs,'rx:'); lsline
    xlabel('Day of Training')
    ylabel('RT (s)'); ylim([-1 20])
    
    
    subplot(4,1,3)
    yyaxis left
    bar((1:length(maus_or_means))+0.2,maus_or_means,0.3)
    ylim([0 1]); ylabel('Percent Success')
    hold on
%     er = errorbar((1:length(maus_or_means))+0.2,maus_or_means,maus_or_STDs*2);
%     er.Color = [0 0 0];
%     er.LineStyle = 'none';
    
    yyaxis right
    xlim([0.1 length(RTs_or_means)+0.9])
    %     keyboard
    bar((1:length(RTs_or_means)) - 0.2, RTs_or_means,0.18)
    xticklabels({'0-10','20-30','40-50','60-70','80-90','100-110','120-130','140-150','160-170'})
    ylabel('RT (s)'); ylim([0 20])
    xlim([0.1 length(RTs_or_means)+0.9])
    hold on
    er = errorbar((1:length(RTs_or_means)) - 0.2, RTs_or_means,RTs_or_STDs);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
    
    
    subplot(4,1,4)
    bar((1:length(n_trials_ors)), n_trials_ors)
    xticklabels({'0-10','20-30','40-50','60-70','80-90','100-110','120-130','140-150','160-170'})
    ylabel('Number of trials');
    
    all_mice_means(mouse_ind,:) = maus_or_means;
     all_mice_RTs(mouse_ind,:) = RTs_or_means;
     
    
     
    clear   n_trials  n_trials_ors  maus_or_means RTs_or_means RTs_or_STDs maus_or_STDs  RTs
saveas(aa,maus_dat{mouse_ind}{end,3},'bmp')


end

figure
    yyaxis left
    bar((1:length(mean(all_mice_means,1)))+0.2,mean(all_mice_means,1),0.3)
    ylim([0 1]); ylabel('Percent Success')
    hold on
    
      yyaxis right
    xlim([0.1 length(mean(all_mice_RTs,1))+0.9])
    %     keyboard
    bar((1:length(mean(all_mice_RTs,1))) - 0.2, mean(all_mice_RTs,1),0.18)
    xticklabels({'0-10','20-30','40-50','60-70','80-90','100-110','120-130','140-150','160-170'})
    ylabel('RT (s)'); ylim([0 20])
    xlim([0.1 length(mean(all_mice_RTs,1))+0.9])
   
    
    
    
    
    
    
    
    