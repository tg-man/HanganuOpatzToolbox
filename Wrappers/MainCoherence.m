%% load experiment info and set a few variables for analysis

clear
% load experiments and generic stuff
experiments = get_experiment_redux;
experiments = experiments([64:67]); 
repeatCalc = 1;
save_data = 1;
% the number of CPU cores to use to load signal. Unless you are doing
% nothing else on your computer, do not use all of them. Otherwise you will
% end with no processing power for anything else
cores = 6; 

% loading and filtering variables
fs = 32000; % from data
downsampling_factor = 100; % downsample for LFP analysis
fs_LFP = fs / downsampling_factor;
high_cut = fs / downsampling_factor / 2; % nyquist
ExtractMode = 1; % extract from neuralynx into matlab
ch2load = 1:48; % select channels to load

% coherence variables
win_length = 4; % window length for coherence (in seconds)
overlap = win_length / 2; % window overlap for coherence (in seconds)
nfft = 2^13; % number of points for power spectrum (coherence)

% folders to save various results
folder4Coh = 'Q:\Personal\Tony\Analysis\Results_3Probe_Coh_coactive\'; 
folder4coactive = 'Q:\Personal\Tony\Analysis\Results_3Probe_Coactive\All3_NoArtifact\';

%% Rewritten 

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
    LFP3 = nanmedian(LFP(33:48,:)); %TH signal 
    clear LFP 
    
    % optional: select only coactive periods for calculation
    load(strcat(folder4coactive, experiment.animal_ID)); 
    coactive = logical(CoactivePeriods.coactive); 
    LFP1 = LFP1(coactive); 
    LFP2 = LFP2(coactive); 
    LFP3 = LFP3(coactive); 

    % compute coherence
    disp(['computing coherence for animal number ' num2str(exp_idx)])
    getCoherence(LFP1, LFP2, fs_LFP, win_length, overlap, nfft, folder4Coh, ...
        experiment.animal_ID, experiment.Area1, experiment.Area2, repeatCalc, save_data)
    getCoherence(LFP1, LFP3, fs_LFP, win_length, overlap, nfft, folder4Coh, ...
        experiment.animal_ID, experiment.Area1, experiment.Area3, repeatCalc, save_data)
    getCoherence(LFP2, LFP3, fs_LFP, win_length, overlap, nfft, folder4Coh, ...
        experiment.animal_ID, experiment.Area2, experiment.Area3, repeatCalc, save_data)
    clear LFP1 LFP2 LFP3
end

%% 
% %% compute all sort of computations, on an experiment by experiment basis
% 
% for exp_idx = 1 : size(experiments, 2)
%     
%     % select experiment
%     experiment = experiments(exp_idx);
%     
%     % load and filter first signal
%     disp(['loading LFP 1 for animal number ' num2str(exp_idx)])
%     parfor (channel = 17:32, cores) %PFC signal
%         file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
%         disp(['loading channel ' num2str(channel)])
%         [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
%         signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); %original lowcut 0
%         LFP1(channel - 16, :) = signal(1 : downsampling_factor : end);
%     end
%     noisy_channels = experiment.NoisyCh;
%     noisy_channels = noisy_channels(ismember(noisy_channels, ch2load));
%     LFP1(noisy_channels - 16, :) = NaN; %Do the same here for noisy channels.
%     clear signal
%     
%     % load and filter second signal
%     disp(['loading LFP 2 for animal number ' num2str(exp_idx)])
%     parfor (channel = 1:16, cores) %Str signal
%         file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
%         disp(['loading channel ' num2str(channel)])
%         [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
%         signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); %original lowcut 0
%         LFP2(channel, :) = signal(1 : downsampling_factor : end);
%     end
%     noisy_channels = experiment.NoisyCh;
%     noisy_channels = noisy_channels(ismember(noisy_channels, ch2load));
%     LFP2(noisy_channels, :) = NaN;
%     clear signal
%     
%         % load and filter third signal
%     disp(['loading LFP 3 for animal number ' num2str(exp_idx)])
%     parfor (channel = 33:48, cores) %TH signal
%         file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
%         disp(['loading channel ' num2str(channel)])
%         [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
%         signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); %original lowcut 0
%         LFP3(channel - 32, :) = signal(1 : downsampling_factor : end);
%     end
%     noisy_channels = experiment.NoisyCh;
%     noisy_channels = noisy_channels(ismember(noisy_channels, ch2load));
%     LFP3(noisy_channels - 32, :) = NaN; %Do the same here for noisy channels.
%     clear signal
% 
%     % average the two signals (depending on your experimental paradigm, 
%     % scientific question and/or electrode configuration, you might want to
%     % skip this part and compute coherence between each pair of channels
%     % and or selected pairs of channels
%     LFP1 = nanmedian(LFP1);
%     LFP2 = nanmedian(LFP2);
%     LFP3 = nanmedian(LFP3); 
%     
%     % keep only good part of the recording
%     if ~ nnz(isnan(experiment.RecKeep))
%         experiment.RecKeep = str2num(experiment.RecKeep);
%         LFP1 = LFP1(:, experiment.RecKeep(1) * fs_LFP : ...
%             experiment.RecKeep(2) * fs_LFP);
%         LFP2 = LFP2(:, experiment.RecKeep(1) * fs_LFP : ...
%             experiment.RecKeep(2) * fs_LFP);
%         LFP3 = LFP3(:, experiment.RecKeep(1) * fs_LFP : ...
%             experiment.RecKeep(2) * fs_LFP);
%     end 
%     
%     % compute coherence
%     disp(['computing coherence for animal number ' num2str(exp_idx)])
%     getCoherence(LFP1, LFP2, fs_LFP, win_length, overlap, nfft, folder4Coh, ...
%         experiment.animal_ID, experiment.Area1, experiment.Area2, repeatCalc, save_data)
%     getCoherence(LFP1, LFP3, fs_LFP, win_length, overlap, nfft, folder4Coh, ...
%         experiment.animal_ID, experiment.Area1, experiment.Area3, repeatCalc, save_data)
%     getCoherence(LFP2, LFP3, fs_LFP, win_length, overlap, nfft, folder4Coh, ...
%         experiment.animal_ID, experiment.Area2, experiment.Area3, repeatCalc, save_data)
%     clear LFP1 LFP2 LFP3    
% end