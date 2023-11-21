function  Tcoeff = getSTTC_ba(experiment, folder4SM, BrainArea1, BrainArea2, lags, repeat_calc, save_data, folder4STTC)
%% Tony Oct 2023 
% 
% Scripts to compute STTC between spikes from different brain areas 
% inputs: 
%     - experiment: from your excel 
%     - folder4SM: where the baseline spike matrices live. Assuming you have a folder with subfolder for differernt brain area, only specify the general folder 
%     - BrainArea1: string, samw as that from the excel. Also applies to BrainArea 2 
%     - lags: vector of time lag in miliseconds 
%     - repeat_calc: 1 or 0 for true or false 
%     - save_data: 1 or 0 for true or false
%     - folder4STTC: output folder. Again, DO NOT give the brain area specific folder! 

% convert lags to seconds
lags = lags / 1000;

if exist([folder4STTC BrainArea1 BrainArea2 '\' experiment.name]) && repeat_calc == 0 
    load([folder4STTC BrainArea1 BrainArea2 '\' experiment.name]); 
else 
    % load spike matrices 
    sm1 = load([folder4SM BrainArea1 filesep experiment.name]).spike_matrix; 
    sm2 = load([folder4SM BrainArea2 filesep experiment.name]).spike_matrix; 

    if sum(sum(sm1)) > 1 && sum(sum(sm2)) > 1 
        len_rec = [0 max([size(sm1, 2) size(sm2, 2)]) / 1000]; % length of recording in seconds 

        % calculate STTC
        for lag_idx = 1 : numel(lags) % lag loop 
            pair_idx = 1;
            for unit1 = 1 : size(sm1, 1) % 1st SM loop 
                num_unit1 = full(sum(sm1(unit1, :))); % number of total spikes from this cell 
                spike_times_1 = find(sm1(unit1, :)) / 1000; % time stamps of these spikes, in seconds
                for unit2 = 1 : size(sm2, 1) % 2nd SM loop 
                    num_unit2 = full(sum(sm2(unit2, :))); 
                    spike_times_2 = find(sm2(unit2, :)) / 1000; 
                    STTC(pair_idx, lag_idx) = getSTTC(num_unit1, num_unit2, lags(lag_idx), len_rec, spike_times_1, spike_times_2); 
                    pair_idx = pair_idx + 1;
                end 
            end 
        end 
    else 
        STTC = []; 
    end 

    if save_data == 1 
        Tcoeff.STTC = STTC; 
        Tcoeff.lags = lags;
        Tcoeff.area1 = BrainArea1; 
        Tcoeff.area2 = BrainArea2; 

        if ~ exist([folder4STTC BrainArea1 BrainArea2 '\'], 'dir')
            mkdir([folder4STTC BrainArea1 BrainArea2 '\']); 
        end 
        save([folder4STTC BrainArea1 BrainArea2 '\' experiment.name], 'Tcoeff')
    else 
        disp('data not saved!'); 
    end 

end % function end 
