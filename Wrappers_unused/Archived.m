%% Archived Scripts that aren't useful at the moment
%% PSD during only coactive periods 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([57:63]); % what experiments to keep
repeatCalc = 1;
save_data = 1;
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
cores = 6;

% PSD variables
freq2analyze = logspace(-1, log10(100), 42); % frequencies to analyze with windows of different length. Originally (-2, log10(50),20)
slow_freqs = [0.2 5]; % slow frequencies (0.01 is the digital filter of our recordings, unless you changed it!)
fast_freqs = [5 100]; % fast frequencies. High cut at 50 originally

% folders to save various results
folder4osc = 'Q:\Personal\Tony\Analysis\Results_3Probe_osc_test\'; 
folder4PSD = 'Q:\Personal\Tony\Analysis\Results_3Probe_PSD_NoArtifact\';

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    
    % load signal and filter for LFP
    disp(['Loading LFP for animal number ' num2str(exp_idx)])
    parfor (channel = ch2load, cores)
        disp(['Loading channel ' num2str(channel)]);
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); % origianlly 0.1
        LFP(channel, :) = signal(1 : downsampling_factor : end);
    end
    clear signal
    noisy_channels = experiment.NoisyCh;
    noisy_channels = noisy_channels(ismember(noisy_channels, ch2load));
    LFP(noisy_channels, :) = NaN; % Do the same here for noisy channels
    
    % keep only good part of the recording
    if ~ nnz(isnan(experiment.RecKeep))
        experiment.RecKeep = str2num(experiment.RecKeep);
        LFP = LFP(:, experiment.RecKeep(1) * fs_LFP : ...
            experiment.RecKeep(2) * fs_LFP);
    end
  
    % CAR (Common average reference) 
    LFP_PFC = LFP(17:32,:) - nanmedian(LFP(17:32,:));
    LFP_Str = LFP(1:16,:) - nanmedian(LFP(1:16,:)); 
    LFP_TH = LFP(33:48,:) - nanmedian(LFP(33:48,:)); 
    clear LFP
    
    % keep only artifact-free periods
    load(strcat(folder4osc, experiment.animal_ID, '_PFC')); 
    artifact_PFC = zeros(1, oscillations.len_rec); 
    for idx = 1:size(oscillations.timestamps_artifact,1)
        artifact_PFC(oscillations.timestamps_artifact(idx,1):oscillations.timestamps_artifact(idx,2)) = 1; 
    end 
    artifact_PFC = logical(artifact_PFC);
    LFP_PFC = LFP_PFC(:, ~artifact_PFC); 
    clear oscillations 
    
    load(strcat(folder4osc, experiment.animal_ID, '_Str')); 
    artifact_Str = zeros(1, oscillations.len_rec); 
    for idx = 1:size(oscillations.timestamps_artifact,1)
        artifact_Str(oscillations.timestamps_artifact(idx,1):oscillations.timestamps_artifact(idx,2)) = 1; 
    end 
    artifact_Str = logical(artifact_Str);
    LFP_Str = LFP_Str(:, ~artifact_Str); 
    clear oscillations 

    load(strcat(folder4osc, experiment.animal_ID, '_TH'));   
    artifact_TH = zeros(1, oscillations.len_rec); 
    for idx = 1:size(oscillations.timestamps_artifact,1)
        artifact_TH(oscillations.timestamps_artifact(idx,1):oscillations.timestamps_artifact(idx,2)) = 1; 
    end 
    artifact_TH = logical(artifact_TH);
    LFP_TH = LFP_TH(:, ~artifact_TH); 
    clear oscillations 

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


%% Load Str Osc and Non-Osc data

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
    load(strcat(folder4osc, experiment.animal_ID, '_Str'));
    timestamps = extractfield(oscillations, 'timestamps');
    time_in_osc(exp_idx,2) = sum(oscillations.durations) ./ oscillations.len_rec;
    num_osc(exp_idx,2) = size(oscillations.durations, 1) / (max(timestamps) / (60*1000));
    duration(exp_idx,2) = nanmedian(oscillations.durations); %in seconds
    amplitude(exp_idx,2) = nanmedian(oscillations.peakAbsPower); 
    amplitude_NO(exp_idx) = nanmedian(oscillations.NonOscPowerAbs); 
end 

amplitude_NO = amplitude_NO'; 
amplitude_NO(:,2) = age; 
amplitude_NO(:,3) = 2; 
amplitude = amplitude(:,2); 
amplitude(:,2) = age;
amplitude(:,3) = 1; 

combined = [amplitude; amplitude_NO]; 
for i = 1:size(combined,1)
    if combined(i,2) == 8 & combined(i,3) == 1
        code(i) = 1; 
    elseif combined(i,2) == 8 & combined(i,3) == 2
        code(i) = 2; 
    elseif combined(i,2) == 9 & combined(i,3) == 1
        code(i) = 3; 
    elseif combined(i,2) == 9 & combined(i,3) == 2 
        code(i) = 4; 
    elseif combined(i,2) == 10 & combined(i,3) == 1
        code(i) = 5; 
    elseif combined(i,2) == 10 & combined(i,3) == 2
        code(i) = 6; 
    end 
end 
code = code'; 

figure; title('Amplitude Osc  vs. Non-Osc (Str)', 'FontSize', 18, 'FontWeight', 'bold'); 
violinplot(log10(combined(:,1)), code); 
ylabel('Log of amplitude (microV)'); set(gca, 'FontSize', 14); 

xticklabels({'P8 Osc', 'P8 Non-Osc', 'P9 Osc', 'P9 Non-Osc', 'P10 Osc', 'P10 Non-Osc'}); 


%% Ms Bio 2013


clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([45]); % what experiments to keep
repeatCalc = 1;
save_data = 1;
cores = 4;
% the number of CPU cores to use to load signal. Unless you are doing
% nothing else on your computer, do not use all of them. Otherwise you will
% end with no processing power for anything else

% loading and filtering variables
fs = 32000; % sampling rate from data
downsampling_factor = 160; % downsample for LFP analysis
fs_LFP = fs / downsampling_factor;
high_cut = fs_LFP / 2; % nyquist frequency: the number of data points per second. Max high cut should be half of sampling frequency
ExtractMode = 1; % extract from neuralynx into matlab
ch2load = 1:32; % select channels to load

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
folder4osc = 'Q:\Personal\Tony\MScBio_20130117\osc\'; %Fill in path where to save oscillations
folder4PSD = 'Q:\Personal\Tony\MScBio_20130117\psd\'; %Fill in path where to save PSD


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
    clear signal
    noisy_channels = experiment.NoisyCh;
    noisy_channels = noisy_channels(ismember(noisy_channels, ch2load));
    LFP(noisy_channels, :) = NaN; % Do the same here for noisy channels
    
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

    % plot median of LFP for visual check
    figure; 
    subplot(2,1,1); plot(LFP4osc_PFC); title('PFC');
    subplot(2,1,2); plot(LFP4osc_Str); title('Str');
    sgtitle(['mouse ' experiment.animal_ID]);
    saveas(gcf, fullfile(folder4osc, experiment.animal_ID))
    
    % detect oscillations
    disp(['detecting oscillations for animal number ' num2str(exp_idx)])
    osc_PFC = getOscillations(experiment, LFP4osc_PFC, fs_LFP, freq_band, rel_thresholds, ...
        abs_thresholds, threshold_artifact, durations, save_data, repeatCalc, folder4osc, 1, experiment.Area1, verbose);     
    osc_Str = getOscillations(experiment, LFP4osc_Str, fs_LFP, freq_band, rel_thresholds, ...
        abs_thresholds, threshold_artifact, durations, save_data, repeatCalc, folder4osc, 1, experiment.Area2, verbose); 
    clear LFP4osc_Str LFP4osc_PFC
  
    % CAR (Common average reference) 
    LFP_PFC = LFP(17:32,:) - nanmedian(LFP(17:32,:));
    LFP_Str = LFP(1:16,:) - nanmedian(LFP(1:16,:)); 
    clear LFP

    % compute PSDs
    disp(['computing PSD for animal number ' num2str(exp_idx)])
    PSD_PFC = getPSD_across_timescales(LFP_PFC, fs_LFP, freq2analyze, slow_freqs, fast_freqs, ...
        folder4PSD, experiment.animal_ID, experiment.Area1, save_data);
    PSD_Str = getPSD_across_timescales(LFP_Str, fs_LFP, freq2analyze, slow_freqs, fast_freqs, ...
        folder4PSD, experiment.animal_ID, experiment.Area2, save_data);
    clear LFP_PFC LFP_Str
end

%% SDR MSC Bio 2023
clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([45]); %what experiments to keepfolder4PSD = 'Q:\Personal\Tony\Analysis\Results_2Probe_PSD\'; %Fill in path where to save PSD

folder4PSD = 'Q:\Personal\Tony\MScBio_20130117\psd\'; %Fill in path where to save PSD
folder4SDR = 'Q:\Personal\Tony\MScBio_20130117\sdr\'; %folder where SDR results are saved


% loop: go through each animal, load the PSD's, and calculate SDR 
for exp_idx = 1 : size(experiments, 2)
    
    % select specific experiment for this loop iteration: 
    experiment = experiments(exp_idx);
    
    load(strcat(folder4PSD, experiment.animal_ID, '_PFC'));  % load PSDstruct of PFC generated from last section 
    PSD_PFC = nanmedian(PSDstruct.PSD);   % select only the PSD part of the whole PSDstruct
    clear PSDstruct
    load(strcat(folder4PSD, experiment.animal_ID, '_Str'));  % do the same for Str data  
    PSD_Str = nanmedian(PSDstruct.PSD);
    clear PSDstruct
    
    % call function to actually calculate SDR (layer-specific) 
    disp(['calculating SDR for animal ' num2str(exp_idx)])
    SDR = getSDR(PSD_PFC, PSD_Str, [], []);
    
    % save the file to appropriate folder
    save(strcat(folder4SDR, experiment.animal_ID), 'SDR');
end 

%% Coh 
clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([45]); % what experiments to keep
repeatCalc = 1;
save_data = 1;
% the number of CPU cores to use to load signal. Unless you are doing
% nothing else on your computer, do not use all of them. Otherwise you will
% end with no processing power for anything else
cores = 4; 

% loading and filtering variables
fs = 32000; % from data
downsampling_factor = 100; % downsample for LFP analysis
fs_LFP = fs / downsampling_factor;
high_cut = fs / downsampling_factor / 2; % nyquist
ExtractMode = 1; % extract from neuralynx into matlab
ch2load = 1:32; % select channels to load

% coherence variables
win_length = 4; % window length for coherence (in seconds)
overlap = win_length / 2; % window overlap for coherence (in seconds)
nfft = 2^13; % number of points for power spectrum (coherence)

% folders to save various results
folder4Coh = 'Q:\Personal\Tony\MScBio_20130117\coh\'; 

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    
    % load and filter first signal
    disp(['loading LFP 1 for animal number ' num2str(exp_idx)])
    parfor (channel = ch2load, cores) 
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        disp(['loading channel ' num2str(channel)])
        [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); %original lowcut 0
        LFP(channel, :) = signal(1 : downsampling_factor : end);
    end
    clear signal
    
    noisy_channels = experiment.NoisyCh;
    noisy_channels = noisy_channels(ismember(noisy_channels, ch2load));
    LFP(noisy_channels, :) = NaN; %Do the same here for noisy channels.
    
    % keep only good part of the recording
    if ~ nnz(isnan(experiment.RecKeep))
        experiment.RecKeep = str2num(experiment.RecKeep);
        LFP = LFP(:, experiment.RecKeep(1) * fs_LFP : ...
            experiment.RecKeep(2) * fs_LFP);
    end
    
    LFP1 = nanmedian(LFP(17:32,:)); %PFC signal 
    LFP2 = nanmedian(LFP(1:16,:)); %Str signal 
    clear LFP 

    % compute coherence
    disp(['computing coherence for animal number ' num2str(exp_idx)])
    getCoherence(LFP1, LFP2, fs_LFP, win_length, overlap, nfft, folder4Coh, ...
        experiment.animal_ID, experiment.Area1, experiment.Area2, repeatCalc, save_data)
    clear LFP1 LFP2
end

%%  

Str = sum(oscillations.durations) / oscillations.len_rec
time = [PFC, Str]; 







