
% This example script computes spike-tiling coefficient as described in 
% Cutts et al., 2014 Jneuro. This parameter is a measure of pairwise correlation
% between pairs of spike trains. Importantly for development, it is unbiased by
% firing rate (standard correlation strongly overestimates correlations between
% pairs of spike trains with low firing rate). The parameter "lags" controls the 
% temporal scale at which the coefficient is computed

%% load experiments and set a few variable
clear; 
klusta = 1;
experiments = get_experiment_redux(klusta);
experiments = experiments([68:69]);
lags = [5, 10, 20, 50, 100, 500]; % single lags for which to compute tiling coeff
repeat_calc = 0;
save_data = 1;
stim_period = 'baseline';
output_folder_STTCglobal = 'Q:\Personal\Tony\Analysis\Results_3Probe_STTC\PFC\'; % where to save
% output_folderTilCum = 'YOUR FOLDER HERE'; % where to save
% output_folderGH = 'YOUR FOLDER HERE'; % where to save
resultsKlusta = 'Q:\Personal\Tony\Analysis\Results_3Probe_SUAinfo\PFC\'; % folder in which you have SUA files
output_folder_SM = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\PFC\'; % where to save spike matrix

% Extract unique animals from the experiment list. animals are the "unit"
% around which the rest is calculated
% If you do not have multiple "experiments" (i.e. recordings) for
% the same animal, this part of the code might have redundant parts for
% you.

animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

%% compute xCorr and/or Tiling Coefficient

for animal_idx = 1 : length(animals)
    
    animal_name = cell2mat(animals(animal_idx)); % extract name of the animal
    % load spike matrix
    [spike_matrix, clusters] = getSpikeMatrixBaseline(animal_name, ...
        experiments, resultsKlusta, save_data, repeat_calc, output_folder_SM);
    % compute GLOBAL spike-time tiling coefficient
%     disp(['animal ', animal_name, ' pairs ', num2str(TcHeyyoeff.num_pairs)])   
    disp(['animal ', animal_name])
    getSTTC_global(animal_name, spike_matrix, lags, repeat_calc, save_data, output_folder_STTCglobal);
end









