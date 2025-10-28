%% Firing Rate 
clear; 
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments(); 
folder4osc = 'Q:\Personal\Tony\Analysis\Results_2Probe_osc\'
folder4SUA = 'D:\for_Tony\SUA_info\Str\';
folder4FR = 'Q:\Personal\Tony\Analysis\Results_SUA_FR\Str\'


for exp_idx = 1:size(experiments, 2)
    experiment = experiments(exp_idx); %select specific experiment one by one
    load(strcat(folder4SUA, experiment.animal_ID)); %load SUAinfo 
    rate_matrix = []; %initialize variable
    for i = 1:size(SUAinfo{1,1},2) %loop through each cell
        n = size(SUAinfo{1, 1}(i).Timestamps, 1); %number of spikes
        if experiment.RecKeep == NaN 
            load(strcat(folder4osc, experiment.animal_ID, '_Str')); 
            length = oscillations.len_rec/200;
        else
            timebound = str2num(experiments(1).RecKeep);
            length = timebound(1,2) - timebound(1,1); 
        end
        rate = n/length;
        rate_matrix = [rate_matrix; rate];
        save(strcat(folder4FR, experiment.animal_ID),'rate_matrix'); 
    end
    clear rate_matrix
end 


%% Plot average firing rate 

clear; 
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments(); 
folder4FR_PFC = 'Q:\Personal\Tony\Analysis\Results_SUA_FR\PFC\'; 
folder4FR_Str = 'Q:\Personal\Tony\Analysis\Results_SUA_FR\Str\'; 

for exp_idx = 1:size(experiments, 2)
    experiment = experiments(exp_idx); % select experiment
    age(exp_idx) = experiment.age; % extract age
    
    load(strcat(folder4FR_PFC,experiment.animal_ID))
    fr2plot(exp_idx,1) = nanmedian(rate_matrix); %PFC median firing rate
    clear rate_matrix 
    
    load(strcat(folder4FR_Str,experiment.animal_ID))
    fr2plot(exp_idx,2) = nanmedian(rate_matrix); %Str median firing rate
end 
age = age'; 

colormap = [0.9294 0.9725 0.6941;0.7804 0.9137 0.7059;0.4980 0.8039 0.7333;...
0.2549 0.7137 0.7686; 0.1137 0.5686 0.7529; 0.1333 0.3686 0.6588; 0.1451 0.2039 0.5804;...
0.0314 0.1137 0.3451];

figure; %sgtitle('Fring Rate', 'FontSize', 18, 'FontWeight', 'bold'); 
subplot(121); 
violins = violinplot(fr2plot(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.45);
for n=1:8
    violins(n).ViolinColor = colormap(n,:);
end
title('PFC', 'FontSize', 22); xlabel('Age (P)'); ylabel('Firing Rate (Hz)'); ylim([0 0.34]); set(gca, 'FontSize', 20, 'FontName', 'Arial')
subplot(122); violins = violinplot(fr2plot(:,2), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for n=1:8
    violins(n).ViolinColor = colormap(n,:);
end
title('STR', 'FontSize', 22);
xlabel('Age (P)'); set(gca, 'FontSize',  20, 'FontName', 'Arial'); ylim([0 0.34]); 
set(gcf, 'Position', [100 100 800 420])

%% PSD no CAR 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments(); %what experiments to keep
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

% oscillation detection variables
freq_band = [4 20]; % frequencies on which to detect oscillations. Originally 20
rel_thresholds = [1 2]; % relative low/peak threshold for oscillation detection (stDev)
abs_thresholds = [50 100]; % absolute low/peak threshold for oscillation detection (microV)
durations = [1000 300]; %  min inter-osc duration and min osc duration
verbose = 0;

% PSD variables
freq2analyze = logspace(-1, log10(100), 42); % frequencies to analyze with windows of different length. Originally (-2, log10(50),20)
slow_freqs = [0.2 5]; % slow frequencies (0.01 is the digital filter of our recordings, unless you changed it!)
fast_freqs = [5 100]; % fast frequencies. High cut at 50 originally

% folders to save various results
folder4PSD = 'Q:\Personal\Tony\Analysis\Results_3Probe_PSDnoCAR\'; %Fill in path where to save PSD

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    
    % load signal and filter for LFP
    disp(['loading LFP for animal number ' num2str(exp_idx)])
    parfor (channel = ch2load, cores)
        disp(['Loading channel ' num2str(channel)]);
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); %origianlly 0.1
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
  
    %
    LFP_PFC = LFP(17:32,:);
    LFP_Str = LFP(1:16,:); 
    LFP_TH = LFP(33:48,:); 
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

%% Plot TH osc stuff 

% load experiments and generic stuff
clear 
experiments = get_experiment_redux; 
experiment = experiments(); % what experiments to keep
repeatCalc = 0;
save_data = 1;

% folders to grab various results
folder4osc = 'Q:\Personal\Tony\Analysis\Results_3Probe_osc_THnew\';

% initialize variables
time_in_osc = NaN(size(experiments, 2),1);
num_osc = time_in_osc;
duration = time_in_osc;
amplitude = time_in_osc;
age = NaN(size(experiments, 2), 1);

% compute all sort of computations, on an experiment by experiment basis
for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
    load(strcat(folder4osc, experiment.animal_ID, '_TH'));
    timestamps = extractfield(oscillations, 'timestamps');
    time_in_osc(exp_idx) = sum(oscillations.durations) ./ oscillations.len_rec;
    num_osc(exp_idx) = size(oscillations.durations, 1) / (oscillations.len_rec / (60*200));
    duration(exp_idx) = nanmedian(oscillations.durations / 200); %in seconds
    amplitude(exp_idx) = nanmedian(oscillations.peakAbsPower); 
end

YlGnBu = cbrewer('seq', 'YlGnBu', 100); %call colormap 
figure; violins = violinplot(time_in_osc(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.45);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Time in Active Periods'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Time in Active Periods (TH new)', 'FontSize', 18, 'FontWeight', 'bold');

figure; violins = violinplot(num_osc(:,1), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Count/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Number of Active Periods (TH new)', 'FontSize', 18, 'FontWeight', 'bold');

figure; violins = violinplot(duration(:,1), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Duration of Active Periods (TH new)', 'FontSize', 18, 'FontWeight', 'bold');

figure; violins = violinplot(amplitude(:,1), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Amplitude of Active Periods (TH new)', 'FontSize', 18, 'FontWeight', 'bold');

%% 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([50]); % what experiments to keep
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
ch2load = 33:48; % select channels to load
cores = 6;

% oscillation detection variables
freq_band = [4 20]; % frequencies on which to detect oscillations. Originally 20
rel_thresholds = [1 2]; % relative low/peak threshold for oscillation detection (stDev)
abs_thresholds = [50 100]; % absolute low/peak threshold for oscillation detection (microV)
abs_thresholds_TH = [35 80]; % same as above but for TH area
durations = [1000 300]; %  min inter-osc duration and min osc duration
verbose = 0;

% folders to save various results
folder4osc = 'Q:\Personal\Tony\Analysis\Results_3Probe_osc_test\'; %Fill in path where to save oscillations


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
    LFP4osc_TH = nanmedian(LFP(33:48,:));

    % detect oscillations
    disp(['detecting oscillations for animal number ' num2str(exp_idx)])
    osc_TH = getOscillations(experiment, LFP4osc_TH, fs_LFP, freq_band, rel_thresholds, ...
        abs_thresholds_TH, durations, save_data, repeatCalc, folder4osc, 1, experiment.Area3, verbose); 
    clear LFP4osc_TH 
    clear LFP

end













