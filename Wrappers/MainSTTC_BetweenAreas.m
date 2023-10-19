%% STTC between two different spike matrices 
% Tony, Jan 2023 

clear; 
klusta = 1;
experiments = get_experiment_redux();
experiments = experiments([45:67]);
lags = [5, 10, 20, 50, 100, 500]; % single lags for which to compute tiling coeff, in miliseconds 

folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\';

output_folder_a = 'Q:\Personal\Tony\Analysis\Results_3Probe_STTC\PFC_Str\'; 
output_folder_b = 'Q:\Personal\Tony\Analysis\Results_3Probe_STTC\Str_TH3\'; 
output_folder_c = 'Q:\Personal\Tony\Analysis\Results_3Probe_STTC\TH3_PFC\'; 


% the animal loop
for exp_idx = 1: size(experiments, 2)
    experiment = experiments(exp_idx); 
    SM1 = load([folder4SM1, experiment.animal_ID,'spike_matrix.mat']).spike_matrix; 
    SM2 = load([folder4SM2, experiment.animal_ID,'spike_matrix.mat']).spike_matrix; 
    SM3 = load([folder4SM3, experiment.animal_ID,'spike_matrix.mat']).spike_matrix; 
    
    rec_length = max([size(SM1,2), size(SM2,2), size(SM3,2)])/1000; % set recording length and cover to seconds per requried by getSTTC 
    rec_time = [0 rec_length]; 
    
    % three separate triple for-loops calculating STTC going through each pair of spike trains at each lag
    % first area pair: PFC_Str
    disp(['computing STTC for animal ', num2str(exp_idx), ' out of ', num2str(size(experiments,2))])
    for lag_idx = 1: length(lags) %the lag loop 
        pair_idx = 1; 
        lag = lags(lag_idx)/1000; % select lag time and convert to seconds per required by getSTTC  
        for SM1_idx = 1: size(SM1,1) % the SM1 loop 
            spike_times_1 = find(SM1(SM1_idx,:))/1000; % extract timestamps of spike train 1 and convert to seconds 
            spike_counts_1 = size(spike_times_1, 2); 
            for SM2_idx = 1: size(SM2,1) % the SM2 loop 
                spike_times_2 = find(SM2(SM2_idx,:))/1000; %extract timestamps of spike train 2 and convert to seconds 
                spike_counts_2 = size(spike_times_2,2); 
                STTC(pair_idx, lag_idx) = getSTTC(spike_counts_1, spike_counts_2, lag, rec_time, spike_times_1, spike_times_2); 
                pair_idx = pair_idx + 1; 
            end
        end 
    end 
    % put everything in a structure and save 
    Tcoeff.STTC = STTC; 
    Tcoeff.lags = lags; 
    Tcoeff.areas = 'PFC_Str'; 
    save(strcat(output_folder_a, experiment.animal_ID), 'Tcoeff'); 
    clear STTC Tcoeff
   
    % second area pair: Str_TH3
    for lag_idx = 1: length(lags) %the lag loop 
        pair_idx = 1; 
        lag = lags(lag_idx)/1000; % select lag time and convert to seconds per required by getSTTC  
        for SM2_idx = 1: size(SM2,1) % the SM2 loop 
            spike_times_2 = find(SM2(SM2_idx,:))/1000; % extract timestamps of spike train 2 and convert to seconds 
            spike_counts_2 = size(spike_times_2, 2); 
            for SM3_idx = 1: size(SM3,1) % the SM3 loop 
                spike_times_3 = find(SM3(SM3_idx,:))/1000; % extract timestamps of spike train 3 and convert to seconds 
                spike_counts_3 = size(spike_times_3,2); 
                STTC(pair_idx, lag_idx) = getSTTC(spike_counts_2, spike_counts_3, lag, rec_time, spike_times_2, spike_times_3); 
                pair_idx = pair_idx + 1; 
            end
        end 
    end 
    % put everything in a structure and save 
    Tcoeff.STTC = STTC; 
    Tcoeff.lags = lags; 
    Tcoeff.areas = 'Str_TH3'; 
    save(strcat(output_folder_b, experiment.animal_ID), 'Tcoeff'); 
    clear STTC Tcoeff
    
    % third area pair: TH3_PFC
    for lag_idx = 1: length(lags) %the lag loop 
        pair_idx = 1; 
        lag = lags(lag_idx)/1000; % select lag time and convert to seconds per required by getSTTC  
        for SM1_idx = 1: size(SM1,1) % the SM1 loop 
            spike_times_1 = find(SM1(SM1_idx,:))/1000; % extract timestamps of spike train 1 and convert to seconds 
            spike_counts_1 = size(spike_times_1, 2); 
            for SM3_idx = 1: size(SM3,1) % the SM3 loop 
                spike_times_3 = find(SM3(SM3_idx,:))/1000; %extract timestamps of spike train 3 and convert to seconds 
                spike_counts_3 = size(spike_times_3,2); 
                STTC(pair_idx, lag_idx) = getSTTC(spike_counts_1, spike_counts_3, lag, rec_time, spike_times_1, spike_times_3); 
                pair_idx = pair_idx + 1; 
            end
        end 
    end 
    % put everything in a structure and save 
    Tcoeff.STTC = STTC; 
    Tcoeff.lags = lags; 
    Tcoeff.areas = 'TH3_PFC'; 
    save(strcat(output_folder_c, experiment.animal_ID), 'Tcoeff'); 
    clear STTC Tcoeff
end 

