function RampSTTC = getRampSTTC_layer(experiment, folder4OM, BrainArea1, BrainArea2, folder4SUAinfo, layer, lags, repeat_calc, save_data, folder4OSTTC) 
% Tony Oct 2023 

% assumptions: 
%     - your ramp matrices are 10s long with 1ms resolution, 
%     - ramp starts at 3001ms and ends at 6000ms 
% inputs: 
%     - experiment: from your excel 
%     - folder4OM: where the ramp matrices live. Assuming you have a folder with subfolder for differernt brain area, only specify the general folder 
%     - BrainArea1: string, samw as that from the excel. Also applies to BrainArea 2 
%     - folder4SUAinfo: ACC area specific folder 
%     - layer: which layer from BrainArea1 to use for computation. 'sup' or 'deep'
%     - lags: vector of time lag in miliseconds 
%     - repeat_calc: 1 or 0 for true or false 
%     - save_data: 1 or 0 for true or false
%     - folder4OSTTC: output folder. Again, DO NOT give the brain area specific folder! 


% convert lags to seconds
lags = lags / 1000;

if exist([folder4OSTTC BrainArea1 layer BrainArea2 '\' experiment.name]) && repeat_calc == 0 
    load([folder4OSTTC BrainArea1 layer BrainArea2 '\' experiment.name]); 
else
    % load ramp matrices 
    load([folder4OM BrainArea1 '\' experiment.name]);
    om1 = SUAdata_ramp.ramp_spike_matrix; 
    load([folder4OM BrainArea2 '\' experiment.name]);
    om2 = SUAdata_ramp.ramp_spike_matrix; 
    clear SUAdata_ramp

    % find out which cell from SUAinfo to load
    experiments = get_experiment_redux; 
    experiments = experiments(strcmp(extractfield(experiments, 'animal_ID'), experiment.animal_ID));
    cell2load = find(strcmp(extractfield(experiments, 'name'), experiment.name));
    clear experiments

    % selected ACC spike matrix based on layer input 
    load([folder4SUAinfo experiment.animal_ID])
    channels = [SUAinfo{1, cell2load}.channel]; 
    if strcmp(layer, 'sup') 
        om1 = om1(:, channels < 5, :); 
    elseif strcmp(layer, 'deep') 
        om1 = om1(:, channels > 12, :); 
    end 
    clear SUAinfo

    if ~isempty(om1) && ~isempty (om2) 
        % initialize a pre matrix and during matrix 
        om1_pre = om1;
        om1_during = om1; 
        om2_pre = om2; 
        om2_during = om2; 
        clear om1 om2 
    
        % set all irrelevant period to zero so that only relevant period has spikes
        om1_pre(:, :, 3001:10000) = 0; 
        om1_during(:, :, [1:3000 6001:10000]) = 0; 
        om2_pre(:, :, 3001:10000) = 0; 
        om2_during(:, :, [1:3000 6001:10000]) = 0; 
    
        % permute and reshape to concatenate all the ramps 
        om1_pre = permute(om1_pre, [3 1 2]);
        om1_pre = reshape(om1_pre, size(om1_pre, 1) * size(om1_pre, 2), [])';
        om1_during = permute(om1_during, [3 1 2]);
        om1_during = reshape(om1_during, size(om1_during, 1) * size(om1_during, 2), [])'; 
        om2_pre = permute(om2_pre, [3 1 2]);
        om2_pre = reshape(om2_pre, size(om2_pre, 1) * size(om2_pre, 2), [])';
        om2_during = permute(om2_during, [3 1 2]);
        om2_during = reshape(om2_during, size(om2_during, 1) * size(om2_during, 2), [])'; 
        len_rec = [0 size(om1_pre, 2) / 1000]; 
    
        % compute STTC
        for lag_idx = 1 : numel(lags) % lag loop 
            pair_idx = 1;
            for unit1 = 1 : size(om1_pre, 1) % 1st SM loop 
                num1_pre = full(sum(om1_pre(unit1, :))); % number of total spikes from this cell 
                time1_pre = find(om1_pre(unit1, :)) / 1000; % time stamps of these spikes, in seconds
                num1_during = full(sum(om1_during(unit1, :))); 
                time1_during = find(om1_during(unit1, :)) / 1000; 
                
                for unit2 = 1 : size(om2_pre, 1) % 2nd SM loop 
                    num2_pre = full(sum(om2_pre(unit2, :))); % number of total spikes from this cell 
                    time2_pre = find(om2_pre(unit2, :)) / 1000; % time stamps of these spikes, in seconds
                    num2_during = full(sum(om2_during(unit2, :))); 
                    time2_during = find(om2_during(unit2, :)) / 1000; 
    
                    STTC_pre(pair_idx, lag_idx) = getSTTC(num1_pre, num2_pre, lags(lag_idx), len_rec, time1_pre, time2_pre); 
                    STTC_during(pair_idx, lag_idx) = getSTTC(num1_during, num2_during, lags(lag_idx), len_rec, time1_during, time2_during); 
                    spikenum_pre(pair_idx, :) = [num1_pre num2_pre]; 
                    spikenum_during(pair_idx, :) = [num1_during num2_during]; 
    
                    pair_idx = pair_idx + 1;
                end 
            end 
        end 
     
        % put everything in a struct 
        RampSTTC.STTC_pre = STTC_pre; 
        RampSTTC.STTC_during = STTC_during; 
        RampSTTC.spikenum_pre = spikenum_pre; 
        RampSTTC.spikenum_during = spikenum_during; 
        RampSTTC.lags = lags; 
        RampSTTC.area1 = [BrainArea1 layer]; 
        RampSTTC.area2 = BrainArea2; 

    else 
        RampSTTC.STTC_pre = []; 
        RampSTTC.STTC_during = []; 
        RampSTTC.spikenum_pre = []; 
        RampSTTC.spikenum_during = []; 
        RampSTTC.lags = lags; 
        RampSTTC.area1 = [BrainArea1 layer]; 
        RampSTTC.area2 = BrainArea2; 
    end % emptiness check end 

    if save_data == 1 
        if ~exist([folder4OSTTC BrainArea1 layer BrainArea2 '\'], 'dir') 
            mkdir([folder4OSTTC BrainArea1 layer BrainArea2 '\']); 
        end 
        save([folder4OSTTC BrainArea1 layer BrainArea2 '\' experiment.name], 'RampSTTC'); 
    else 
        disp('data not saved!')
    end 

end 

end % function end 