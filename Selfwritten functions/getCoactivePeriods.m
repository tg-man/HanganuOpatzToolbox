function CoactivePeriods = getCoactivePeriods(experiment, timestamps1, timestamps2, fs, len_rec, save_data, folder2save)
% by Tony. Aug 2023 
% To detect coactive periods of using active period timestamps from getOscillations output 
% input: 
%     experiment: you excel 
%     timestamps1 & 2: from getOscillations output, timestamps of active periods 
%     fs: a single number, frame rate of timestamps 
%     len_rec: a single number, total length of the recording based on fs 
%     folder2save: where to save the result
% Output: 
%     a structure that includes timestamps of coactive periods 

% initialize some variables
coactive = zeros(1,len_rec);
active1 = NaN(1,len_rec);
active2 = NaN(1,len_rec);

for idx = 1 : size(timestamps1, 1)
    active1(timestamps1(idx, 1) : timestamps1(idx, end)) = 1; 
end

for idx = 1 : size(timestamps2, 1)
    active2(timestamps2(idx, 1) : timestamps2(idx, end)) = 1; 
end 

% compare active1 and active2 and, when they are both numbers at the same position, interpolate coactive zero vector with 1 at that position
coactive(~isnan(active1) & ~isnan(active2)) = 1; 
% get timestamps of beginning and end of coactive periods 
start = find(diff(coactive) > 0)';
stop = find(diff(coactive) < 0)';

% correct special cases 
if stop(1) < start(1) % in case coactive period starts at index 1  
    start = [1;start]; 
end 
if length(start) > length(stop) % in case coactive period runs into the end 
    stop = [stop;len_rec]; 
end 
if stop(end) < start(end) %in case both
    start = [1;start]; 
    stop = [stop; len_rec]; 
end 
% drop coactive periods that are shorter than 300ms 
for idx = 1:length(start)
    if stop(idx) - start(idx) < 0.3*fs
        start(idx) = NaN; 
        stop(idx) = NaN; 
    end 
end 

start = start(~isnan(start)); 
stop = stop(~isnan(stop)); 
timestamps_coactive = [start, stop]; 

% put everything in a structure 
CoactivePeriods.animal_ID = experiment.animal_ID; 
CoactivePeriods.name = experiment.name; 
CoactivePeriods.len_rec = len_rec; 
CoactivePeriods.fs = fs; 
CoactivePeriods.coactive = coactive; 
CoactivePeriods.timestamps = timestamps_coactive; 

if save_data == 1
    if ~exist(folder2save, 'dir')
        mkdir(folder2save);
    end 
    save([folder2save, experiment.name], 'CoactivePeriods'); 
end 

end % function end 