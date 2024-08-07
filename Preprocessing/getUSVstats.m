function [USVstats, len_rec] = getUSVstats(file)
% Tony Mar 2024 

% To read the USV exported excel to matlab structure (easy to work with) 
% 

sheet = 'Sheet1'; 
[~,~, raw] = xlsread(file, sheet);

[~, idx_label] = find(strcmp(raw, 'Label')); 
[~, idx_start] = find(strcmp(raw, 'Begin Time (s)'));
[~, idx_stop] = find(strcmp(raw, 'End Time (s)'));
[~, idx_freq_principal] = find(strcmp(raw, 'Principal Frequency (kHz)'));
[~, idx_freq_low] = find(strcmp(raw, 'Low Freq (kHz)')); 
[~, idx_freq_high] = find(strcmp(raw, 'High Freq (kHz)')); 
[~, idx_freq_std] = find(strcmp(raw, 'Frequency Standard Deviation (kHz)')); 
[~, idx_slope] = find(strcmp(raw, 'Slope (kHz/s)')); 
[~, idx_sinuosity] = find(strcmp(raw, 'Sinuosity'));
[~, idx_mean_power] = find(strcmp(raw, 'Mean Power (dB/Hz)'));
[~, idx_freq_peak] = find(strcmp(raw, 'Peak Freq (kHz)')); 
[~, idx_tonality] = find(strcmp(raw, 'Tonality')); 

for row = 1 : (size(raw, 1) - 1)
    USVstats(row).label = str2num(raw{row+1, idx_label}); 
    USVstats(row).start = round(raw{row+1, idx_start}*1000); 
    USVstats(row).stop = round(raw{row+1, idx_stop}*1000); 
    USVstats(row).freq_principal = raw{row+1, idx_freq_principal}; 
    USVstats(row).freq_peak = raw{row+1, idx_freq_peak}; 
    USVstats(row).freq_low = raw{row+1, idx_freq_low}; 
    USVstats(row).freq_high = raw{row+1, idx_freq_high}; 
    USVstats(row).freq_std = raw{row+1, idx_freq_std}; 
    USVstats(row).slope = raw{row+1, idx_slope}; 
    USVstats(row).sinuosity = raw{row+1, idx_sinuosity}; 
    USVstats(row).mean_power = raw{row+1, idx_mean_power}; 
    USVstats(row).tonality = raw{row+1, idx_tonality};
end 

if USVstats(1).label == 9 % check if it's actually the start marker 
    time2sub = USVstats(1).start; 
    for row = 1 : numel(USVstats) 
        USVstats(row).start = USVstats(row).start - time2sub; 
        USVstats(row).stop = USVstats(row).stop - time2sub; 
    end 
    % get rid of the 1st call because it's start marker 
    USVstats(1) = []; 
end 

% check if last is the added end of recording marker 
if USVstats(end).label == 8
    len_rec = USVstats(end).stop; 
    USVstats(end) = []; 
end 

end 