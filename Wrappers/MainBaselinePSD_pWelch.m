%% baseline PSD using pWelch method instead of mtspecgramc

clear
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
cores = 4; 
save_data = 1; 

folder4pwelch = 'Q:\Personal\Tony\Analysis\Results_PSD_pWelch\'; 

% signal processing variables 
ExtractMode = 1; % extract from neuralynx into matlab
downsampling_factor = 32; 

% pWelch variables 
freq_filt = [2 500];
windowSize = 1;
overlap = 0.4;
nfft = 800;
maxFreq = 200;

for exp_idx = 1 : numel(experiments) 
    tic
    experiment = experiments(exp_idx);
    
    if strcmp(experiment.sites, '3site') 
        ch2load = 1 : 48; 
    elseif strcmp(experiment.sites, '2site')
        ch2load = 1 : 32; 
    end 

    % load signal, filter, and compute pWelch for LFP
    disp(['Loading signal ' num2str(exp_idx) ' / ' num2str(numel(experiments))])
    parfor (channel = ch2load, cores) 
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        [~, signal, fs] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs, freq_filt); % origianlly 0.1
        signal = signal(1 : downsampling_factor : end);
        [PSD(channel, :), freq(channel, :)] = pWelchSpectrum(signal, windowSize, overlap, nfft, fs / downsampling_factor, maxFreq); 
    end

    % build struct 
    PSDpWelch.PSD = PSD; 
    PSDpWelch.freq = freq(1, :); 

    % save data 
    if save_data == 1 
        if ~exist(folder4pwelch, 'dir')
            mkdir(folder4pwelch)
        end 
        save([folder4pwelch experiment.name], 'PSDpWelch')
    end 
    
    clear PSD freq

    toc
end 