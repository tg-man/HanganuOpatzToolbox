%% coactive periods detection 
%  using the oscillation struct from BasicLFPAnalysis to generate timestamps
%  of coactive periods between signals of different area from the same
%  multi-site recording 

clear
experiments = get_experiment_redux;
experiments = experiments([70:72]); % what experiments to keep
folder4osc = 'Q:\Personal\Tony\Analysis\Results_3Probe_osc\';
folder4coactive = 'Q:\Personal\Tony\Analysis\Results_3Probe_Coactive\All3_NoArtifact\';
save_data = 1; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this below can be written into a function, can name it getCoactive or
% something along those lines 

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);

    % load oscillation struct 1
    load(strcat(folder4osc, experiment.animal_ID, '_', experiment.Area1));
    % extract all timestamps
    timestamps1 = oscillations.timestamps; 
    % get some other parameters
    fs = oscillations.fs; 
    len_rec = oscillations.len_rec; 
    clear oscillations

    % load oscillation struct 2
    load(strcat(folder4osc, experiment.animal_ID, '_', experiment.Area2));
    % extract all timestamps 
    timestamps2 = oscillations.timestamps; 
    clear oscillations 
 
    % load oscillation struct 3
    load(strcat(folder4osc, experiment.animal_ID, '_', experiment.Area3));
    % extract all timestamps 
    timestamps3 = oscillations.timestamps; 
    clear oscillations 
    
    active1 = nan(1, len_rec); 
    active2 = nan(1, len_rec);
    active3 = nan(1, len_rec); 
    coactive = zeros(1,len_rec);
    
    % interpolate the NaN vector with 1's during active periods 
    for idx = 1: size(timestamps1,1)
        active1(timestamps1(idx,1):timestamps1(idx,end))= 1; 
    end
    
    for idx = 1: size(timestamps2,1)
        active2(timestamps2(idx,1):timestamps2(idx,end))= 1;
    end
    
    for idx = 1: size(timestamps3,1)
        active3(timestamps3(idx,1):timestamps3(idx,end))= 1;
    end
    
    disp(['detecting coactive periods for animal number ' num2str(exp_idx)])
    % compare active1 and active2 and, when they are both numbers at the same position, interpolate coactive zero vector with 1 at that position
%     coactive(~isnan(active1) & ~isnan(active2)) = 1; 
    coactive(~isnan(active1) & ~isnan(active2) & ~isnan(active3)) = 1; 
    
    % extra timestamps of beginning and end of coactive periods 
    start = find(diff(coactive) > 0)';
    stop = find(diff(coactive) < 0)';
    
    % correct special cases 
    if stop(1) < start(1) 
        start = [1;start]; 
    end 
    if length(start) > length(stop) % in case coactive period runs into the end 
        stop = [stop;length(coactive)]; 
    end 
    if stop(end) < start(end) %in case both
        start = [1;start]; 
        stop = [stop; length(coactive)]; 
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
    CoactivePeriods.len_rec = len_rec; 
    CoactivePeriods.fs = fs; 
    CoactivePeriods.coactive = coactive; 
    CoactivePeriods.timestamps = timestamps_coactive; 
    CoactivePeriods.Areas = 'All 3'; % !!!!! change this note depending on the specific experiment!!!!! 
    
    if save_data == 1
        save(strcat(folder4coactive, experiment.animal_ID), 'CoactivePeriods'); 
    end 
end 

