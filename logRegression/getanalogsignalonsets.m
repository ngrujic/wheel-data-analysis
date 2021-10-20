function [pd_onset_seconds,pd_onset_idx] = getanalogsignalonsets(inputSignal, photodiode_threshold, photodiode_sampling_freq, min_ISI_secs,saveit,savename,invert_signal)
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
pd_above_thres_idx = find(normalized_photodiode_data > photodiode_threshold);
pd_above_thres_idx = [-1 pd_above_thres_idx'];
pd_above_thres_interval = diff(pd_above_thres_idx);
% keyboard
idx = find(pd_above_thres_interval > min_ISI_secs * photodiode_sampling_freq); %this finds the offset
idx = idx + 1; %otherwise you get the offset
pd_onset_idx = pd_above_thres_idx(idx);
pd_onset_seconds = pd_onset_idx/photodiode_sampling_freq;
pd_offset_seconds = pd_above_thres_idx(idx)/photodiode_sampling_freq;

if report == 1
   
   
    plot((1:length(normalized_photodiode_data))/photodiode_sampling_freq, normalized_photodiode_data, '.-')
    hold all
    plot(pd_onset_seconds, zeros(1,length(pd_onset_idx)), 'gx')
    plot(pd_offset_seconds, zeros(1,length(pd_onset_idx)), 'rx')    
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