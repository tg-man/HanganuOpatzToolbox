%% load experiment info and set a few variables for analysis

clear
% load experiments and generic stuff
experiments = get_experiment_redux; 
experiments = experiments([205:233]); % what experiments to keep
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
repeatCalc = 1;
save_data = 1;
% the number of CPU cores to use to load signal. Unless you are doing
% nothing else on your computer, do not use all of them. Otherwise you will
% end with no processing power for anything else
cores = 6; 

% loading and filtering variables
fs = 32000; % from data
downsampling_factor = 160; % downsample for LFP analysis
fs_LFP = fs / downsampling_factor;
high_cut = fs / downsampling_factor / 2; % nyquist
ExtractMode = 1; % extract from neuralynx into matlab

% coherence variables
win_length = 4; % window length for coherence (in seconds)
overlap = win_length / 2; % window overlap for coherence (in seconds)
nfft = 2^11; % number of points for power spectrum (coherence), 2^13 was the first 

% folders to save various results
folder4Coh = 'Q:\Personal\Tony\Analysis\Results_Coherence\';
folder4coactive = 'Q:\Personal\Tony\Analysis\Results_Coactive\';

%% Rewritten 

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    
    % load and filter first signal
    disp(['loading signal exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
    if strcmp(experiment.sites, '2site') 
        ch2load = 1:32; 
    elseif strcmp(experiment.sites, '3site')
        ch2load = 1:48; 
    end     
    parfor (channel = ch2load, cores) 
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); % original lowcut 0
        LFP(channel, :) = signal(1 : downsampling_factor : end);
    end

    % set bad channels to NaN 
    bad_ch = [experiment.NoisyCh, experiment.OffCh];
    bad_ch = bad_ch(ismember(bad_ch, ch2load));
    LFP(bad_ch, :) = NaN; % Do the same here for noisy channels
    
    % keep only good part of the recording
    if ~ nnz(isnan(experiment.RecKeep))
        experiment.RecKeep = str2num(experiment.RecKeep);
        LFP = LFP(:, experiment.RecKeep(1) * fs_LFP : experiment.RecKeep(2) * fs_LFP);
    end
    
    LFP1 = nanmedian(LFP(17:32,:)); % ACC signal
    LFP2 = nanmedian(LFP(1:16,:)); % Str signal
    if strcmp(experiment.sites, '3site')
        LFP3 = nanmedian(LFP(33:48,:)); % TH signal
    end 
    clear LFP 

    % compute coherence
    disp(['computing coherence exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
    if experiment.target1 == 1 && experiment.target2 == 1 
        load([folder4coactive, 'ACCStr\' experiment.name]); % load coactive periods property 
        coactive12 = logical(CoactivePeriods.coactive); 
        getCoherence(LFP1(coactive12), LFP2(coactive12), fs_LFP, win_length, overlap, nfft, [folder4Coh 'ACCStr\'], ...
            experiment, repeatCalc, save_data); 
    end 
    if strcmp(experiment.sites, '3site') && experiment.target1 == 1 && experiment.target3 == 1 
        load([folder4coactive, 'ACCTH\' experiment.name]); % load coactive periods property 
        coactive13 = logical(CoactivePeriods.coactive);
        getCoherence(LFP1(coactive13), LFP3(coactive13), fs_LFP, win_length, overlap, nfft, [folder4Coh 'ACCTH\'], ...
            experiment, repeatCalc, save_data); 
    end 
    clear LFP1 LFP2 LFP3

end
