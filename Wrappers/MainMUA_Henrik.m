%% load experiment info and set a few variables for analysis

clear all;

% load experiments and generic stuff
experiments = get_experiment_redux2;
experiments = experiments (); %what experiments to keep
 repeatCalc = 1;
  save_data = 1;
% the number of CPU cores to use to load signal. Unless you are doing
% nothing else on your computer, do not use all of them. Otherwise you will
% end with no processing power for anything else
      cores = 4;

% loading and filtering variables
         fs = 32000; % from data
ExtractMode = 1; % extract from neuralynx into matlab
    ch2load = 25; %17:32% select channels to load
        thr = 5;
FrequencyBandMUA = [500 5000];

             folder4MUA = 'Q:\Personal\Tony\Analysis\AllMua\';
folder4MUA_spike_matrix = 'Q:\Personal\Tony\Analysis\AllMua\MUA Spikes\';
             brain_area = 'PL';

fr=[];
             
%% compute all sort of computations, on an experiment by experiment basis

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% LFP analysis %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % load signal and filter for LFP
    disp(['loading LFP for animal number ' num2str(exp_idx)])
    parfor (channel = ch2load, cores)
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
        LFP(channel - 16, :) = signal;
    end
    noisy_channels = experiment.NoisyCh;
    noisy_channels = noisy_channels(ismember(noisy_channels, ch2load));
    LFP(noisy_channels - 16, :) = NaN;
    
    
    % keep only good part of the recording
    if ~ nnz(isnan(experiment.RecKeep))
        experiment.RecKeep = str2num(experiment.RecKeep);
        LFP = LFP(:, experiment.RecKeep(1) * fs : ...
            experiment.RecKeep(2) * fs);
        
    end
    
    
    
    
    % compute MUA spike times and amplitudes for each channel
%     parfor (ch_idx = 1 : size(LFP, 1), cores)
LFP=LFP(end,:);
for ch_idx=1
        [timestamps, amplitude] = getMUAspiketimes(LFP(ch_idx, :), fs, FrequencyBandMUA, thr);
        MUA(ch_idx).timestamps = timestamps;
        MUA(ch_idx).amplitude = amplitude;
    end    
    % save data
    if save_data == 1
        if ~ exist(folder4MUA, 'dir')
            mkdir(folder4MUA)
        end
        save(strcat(strcat(folder4MUA, experiment.animal_ID, '_', brain_area)), 'MUA')
    end  
    
    recDur=size(LFP,2)/fs;
    fr(exp_idx)=numel(timestamps)/recDur;
    
    
    clear LFP
%     % compute MUA spike matrix
%     spike_matrix = getMUASpikeMatrix(experiment.animal_ID, ...
%         folder4MUA, folder4MUA_spike_matrix, save_data, repeatCalc, brain_area);

    
    
end
