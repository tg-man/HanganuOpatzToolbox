%% STTC between two different spike matrices 
% Tony, Jan 2023 

clear; 
klusta = 1;
experiments = get_experiment_redux(klusta);
experiments = experiments([45:67]);
lags = [5, 10, 20, 50, 100, 500]; % single lags for which to compute tiling coeff, in miliseconds 

folder4SM1 = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\PFC\'; % path to spike matrices of brain area 1, finished with a slash / 
folder4SM2 = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\Str\'; % path to spike matrices of brain area 2
folder4SM3 = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\TH3\'; % path to spike matrices of brain area 3

output_folder = 'Q:\Personal\Tony\Analysis\Results_3Probe_STTC\PFC_Str'; 



% the animal loop, first pair
for exp_id = 1: size(experiments, 2)
    experiment = experiments(exp_id); 
    SM1 = load([folder4SM1, experiment.animal_ID,'spike_matrix.mat']).spike_matrix; 
    SM2 = load([folder4SM2, experiment.animal_ID,'spike_matrix.mat']).spike_matrix; 
    
    % triple for-loop calculating STTC going through each pair of spike trains at each lag 
    disp(['computing STTC for animal ', num2str(exp_idx), ' out of ', size(experiments,2)])
    for lag_idx = 1: length(lags) %the lag loop 
        pair_idx = 1; 
        lag = lags(lag_idx); 
        for SM1_idx = 1: size(SM1,1) % the SM1 loop 
            spike_times_1 = find(SM1(SM1_idx,:));
            spike_counts_1 = size(spike_times_1, 2); 
            for SM2_idx = 1: size(SM2,2) % the SM2 loop 
                spike_times_2 = find(SM2(SM2_idx,:)); 
                spike_counts_2 = size(spike_times_2,2); 
                STTC(pair_idx, lag_idx) = getSTTC( , , lag, , , , ) % use the function to calculate the pair
                pair_idx = pair_idx + 1; 
            end
        end 
    end 
end 

