
% This example script computes spike-tiling coefficient as described in 
% Cutts et al., 2014 Jneuro. This parameter is a measure of pairwise correlation
% between pairs of spike trains. Importantly for development, it is unbiased by
% firing rate (standard correlation strongly overestimates correlations between
% pairs of spike trains with low firing rate). The parameter "lags" controls the 
% temporal scale at which the coefficient is computed

%% load experiments and set a few variable

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments(250:281);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
cores = 4; 

BrainArea = 'TH'; % ACC, Str, TH 
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 

folder4SUAinfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\'; 

lags = [5, 10, 20, 50, 100, 500]; % single lags for which to compute tiling coeff
repeat_calc = 0;
save_data = 1;
folder4STTC = 'Q:\Personal\Tony\Analysis\Results_STTC\';

parfor (exp_idx = 1 : size(experiments, 2), cores)
    experiment = experiments(exp_idx); 
    
    area_idx = find([strcmp(BrainArea, experiment.Area1) strcmp(BrainArea, experiment.Area2) strcmp(BrainArea, experiment.Area3)]); 

    if ~isempty(area_idx) && experiment.(['target' num2str(area_idx)]) == 1 
        disp(['running exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
        spike_matrix = load([folder4SM BrainArea filesep experiment.name]).spike_matrix; 
        getSTTC_global(experiment.animal_ID, spike_matrix, lags, repeat_calc, save_data, [folder4STTC BrainArea '\']);
        getSTTCdist(experiment, BrainArea, folder4SUAinfo, repeat_calc, save_data, [folder4STTC 'Distance\']);
    end 
end 

datetime 

% Extract unique animals from the experiment list. animals are the "unit"
% around which the rest is calculated
% If you do not have multiple "experiments" (i.e. recordings) for
% the same animal, this part of the code might have redundant parts for
% you.

% animals = extractfield(experiments, 'animal_ID');
% animals = animals(~cellfun('isempty', animals));
% animals = unique(cellfun(@num2str, animals, 'un', 0));

% %% compute xCorr and/or Tiling Coefficient
% 
% for animal_idx = 1 : length(animals)
%     
%     animal_name = cell2mat(animals(animal_idx)); % extract name of the animal
%     % load spike matrix
%     [spike_matrix, clusters] = getSpikeMatrixBaseline(animal_name, ...
%         experiments, resultsKlusta, save_data, repeat_calc, output_folder_SM);
%     % compute GLOBAL spike-time tiling coefficient
% %     disp(['animal ', animal_name, ' pairs ', num2str(TcHeyyoeff.num_pairs)])   
%     disp(['animal ', animal_name])
%     getSTTC_global(animal_name, spike_matrix, lags, repeat_calc, save_data, output_folder_STTCglobal);
% end

