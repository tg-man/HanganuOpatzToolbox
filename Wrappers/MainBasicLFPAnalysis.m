
%% load experiment info and set a few variables for analysis
%% Base-script written by Dr. Mattia Chini 2020., furhter modified by Henrik Østby 2020-2021

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([94:122]); % what experiments to keep
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
repeatCalc = 1;
save_data = 1;
cores = 6;
% the number of CPU cores to use to load signal. Unless you are doing
% nothing else on your computer, do not use all of them. Otherwise you will
% end with no processing power for anything else

% loading and filtering variables
fs = 32000; % sampling rate from data
downsampling_factor = 160; % downsample for LFP analysis
fs_LFP = fs / downsampling_factor;
high_cut = fs_LFP / 2; % nyquist frequency: the number of data points per second. Max high cut should be half of sampling frequency
ExtractMode = 1; % extract from neuralynx into matlab
ch2load = 1:48; % select channels to load

% oscillation detection variables
freq_band = [4 20]; % frequencies on which to detect oscillations. Originally 20
rel_thresholds = [1 2]; % relative low/peak threshold for oscillation detection (stDev)
abs_thresholds = [50 100]; % absolute low/peak threshold for oscillation detection (microV)
abs_thresholds_TH = [35 80]; % same as above but for TH area
threshold_artifact = [2000 8]; 
durations = [1000 300]; %  min inter-osc duration and min osc duration
verbose = 0;

% PSD variables
freq2analyze = logspace(-1, log10(100), 42); % frequencies to analyze with windows of different length. Originally (-2, log10(50),20)
slow_freqs = [0.2 5]; % slow frequencies (0.01 is the digital filter of our recordings, unless you changed it!)
fast_freqs = [5 100]; % fast frequencies. High cut at 50 originally

% folders to save various results
folder4osc = 'Q:\Personal\Tony\Analysis\Results_3Probe_osc\'; %Fill in path where to save oscillations
folder4PSD = 'Q:\Personal\Tony\Analysis\Results_3Probe_PSD\'; %Fill in path where to save PSD


%% compute all sort of computations, on an experiment by experiment basis

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% LFP analysis %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % load signal and filter for LFP
    disp(['Loading LFP for animal number ' num2str(exp_idx)])
    parfor (channel = ch2load, cores)
        disp(['Loading channel ' num2str(channel)]);
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); % origianlly 0.1
        LFP(channel, :) = signal(1 : downsampling_factor : end);
    end
    bad_ch = [experiment.NoisyCh,experiment.OffCh];
    bad_ch = bad_ch(ismember(bad_ch, ch2load));
    LFP(bad_ch, :) = NaN; % Do the same here for noisy channels
    
    %%% this is here as an example of how to limit baseline analysis to
    %%% pre opto periods, in case your file has opto stimulations. you can
    %%% delete this part if you are only recording baseline
    
    % load stimulation properties
    %%load([folder4StimProp, experiment.animal_ID, '/StimulationProperties'])
    % extract first stimulation and convert it to samp freq used for LFP
    %%FirstStim = round((StimulationProperties{1, 10} - fs) / downsampling_factor);
    % only take baseline part of LFP
    %%LFP = LFP(:, 1 : FirstStim);
    
    % keep only good part of the recording
    if ~ nnz(isnan(experiment.RecKeep))
        experiment.RecKeep = str2num(experiment.RecKeep);
        LFP = LFP(:, experiment.RecKeep(1) * fs_LFP : ...
            experiment.RecKeep(2) * fs_LFP);
    end
    
    % take median of all channels
    LFP4osc_PFC = nanmedian(LFP(17:32,:));
    LFP4osc_Str = nanmedian(LFP(1:16,:));
    LFP4osc_TH = nanmedian(LFP(33:48,:));
    % plot median of LFP for visual check
    figure; 
    subplot(3,1,1); plot(LFP4osc_PFC); title('PFC');
    subplot(3,1,2); plot(LFP4osc_Str); title('Str');
    subplot(3,1,3); plot(LFP4osc_TH); title('TH'); 
    sgtitle(['mouse ' experiment.animal_ID]);
    saveas(gcf, fullfile(folder4osc, experiment.animal_ID))
    
    % detect oscillations
    disp(['detecting oscillations for animal number ' num2str(exp_idx)])
    osc_PFC = getOscillations(experiment, LFP4osc_PFC, fs_LFP, freq_band, rel_thresholds, ...
        abs_thresholds, threshold_artifact, durations, save_data, repeatCalc, folder4osc, 1, experiment.Area1, verbose);     
    osc_Str = getOscillations(experiment, LFP4osc_Str, fs_LFP, freq_band, rel_thresholds, ...
        abs_thresholds, threshold_artifact, durations, save_data, repeatCalc, folder4osc, 1, experiment.Area2, verbose);
    osc_TH = getOscillations(experiment, LFP4osc_TH, fs_LFP, freq_band, rel_thresholds, ...
        abs_thresholds_TH, threshold_artifact, durations, save_data, repeatCalc, folder4osc, 1, experiment.Area3, verbose); 
    clear LFP4osc_Str LFP4osc_PFC LFP4osc_TH
  
    % CAR (Common average reference) 
    LFP_PFC = LFP(17:32,:) - nanmedian(LFP(17:32,:));
    LFP_Str = LFP(1:16,:) - nanmedian(LFP(1:16,:)); 
    LFP_TH = LFP(33:48,:) - nanmedian(LFP(33:48,:)); 
    clear LFP

    % compute PSDs
    disp(['computing PSD for animal number ' num2str(exp_idx)])
    PSD_PFC = getPSD_across_timescales(LFP_PFC, fs_LFP, freq2analyze, slow_freqs, fast_freqs, ...
        folder4PSD, experiment.animal_ID, experiment.Area1, save_data);
    PSD_Str = getPSD_across_timescales(LFP_Str, fs_LFP, freq2analyze, slow_freqs, fast_freqs, ...
        folder4PSD, experiment.animal_ID, experiment.Area2, save_data);
    PSD_TH = getPSD_across_timescales(LFP_TH, fs_LFP, freq2analyze, slow_freqs, fast_freqs, ...
        folder4PSD, experiment.animal_ID, experiment.Area3, save_data);
    clear LFP_PFC LFP_Str LFP_TH
end
%
% if save_data == 1
%         if ~ exist(folder4LFP, 'dir')
%             mkdir(folder4LFP)
%         end
%         save(strcat(strcat(folder4LFP, experiment.animal_ID)), 'SDR1')
% end


%% Osc over LFP 
% figure; 
% plot(LFP4osc_Str)
% hold on 
% for j = 1:size(oscillations.timestamps,1) 
%     plot(oscillations.timestamps(j,1):oscillations.timestamps(j,end), LFP4osc_Str(oscillations.timestamps(j,1):oscillations.timestamps(j,end)), 'color', 'r'); hold on
% end
