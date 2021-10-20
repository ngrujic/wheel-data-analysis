function [pd_onset_seconds,pd_onset_idx] = getanalogsignalonsets_pupil(inputSignal, photodiode_threshold, photodiode_sampling_freq, min_ISI_secs,saveit,savename,invert_signal,min_onset_dur)
% inputSignal, photodiode_threshold, photodiode_sampling_freq, min_ISI_secs,saveit,savename,invert_signal
report = 1;
plot_photodiode = 1;

data = inputSignal;
photodiode_raw_data = data;
recording_duration = length(data)/photodiode_sampling_freq;

if invert_signal
    photodiode_raw_data = -photodiode_raw_data;
end

normalized_photodiode_data = photodiode_raw_data - min(photodiode_raw_data);
normalized_photodiode_data = normalized_photodiode_data/max(normalized_photodiode_data);

normalized_photodiode_data(normalized_photodiode_data >0.5) = 1;

normalized_photodiode_data(normalized_photodiode_data <0.5) = 0;

pd_above_thres_idx = find(normalized_photodiode_data > photodiode_threshold);
pd_above_thres_idx = [0 pd_above_thres_idx];
pd_above_thres_interval = diff(pd_above_thres_idx);
pd_above_thres_interval = pd_above_thres_interval(pd_above_thres_interval > 1);
pd_above_thres_interval = pd_above_thres_interval(1:end);
pd_above_thres_idx = find( diff([0 normalized_photodiode_data]) >= 1);

pd_below_thres_idx = find(normalized_photodiode_data < photodiode_threshold);
pd_below_thres_idx = [0 pd_below_thres_idx];
pd_below_thres_interval = diff(pd_below_thres_idx);
pd_below_thres_interval = pd_below_thres_interval(pd_below_thres_interval > 1);


shortTrialDelIdx = (pd_below_thres_interval < min_onset_dur);
pd_above_thres_idx(shortTrialDelIdx) = [];



% delind = find(abs(zscore(pd_above_thres_interval - min_ISI_secs(1:length(pd_above_thres_interval))))>2,1)
% pd_above_thres_interval(delind) = [];

idx = find(pd_above_thres_interval > min_ISI_secs); %this finds the offset

if pd_above_thres_interval(1) < min_ISI_secs
idx = idx(2:end); %otherwise you get the offset
end
pd_onset_idx = pd_above_thres_idx;
pd_onset_seconds = pd_onset_idx/photodiode_sampling_freq;
% pd_offset_seconds = pd_above_thres_idx(idx)/photodiode_sampling_freq;

if report == 1
    
    figure(1)
    plot((1:length(normalized_photodiode_data)), normalized_photodiode_data, '.-')
    hold all
    plot(pd_onset_idx, zeros(1,length(pd_onset_idx)), 'gx')
    plot(pd_onset_idx, zeros(1,length(pd_onset_idx)), 'rx')
    hold all
    dx = 0.3; dy = 0.3;
    c = num2str((1:length(pd_onset_idx))');
    
    text(pd_onset_idx, zeros(1,length(pd_onset_idx)), c,'Fontsize', 15);
elseif report == 2
    figure%('name', 'ISIs')
    plot(normalized_photodiode_data(1:end))
    
end

fprintf('found %d onsets\n', length(pd_onset_seconds));
recording_length = length(normalized_photodiode_data);

if saveit == 1;
    save(savename,'pd_onset_idx')
end

end