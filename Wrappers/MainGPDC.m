%% script to calculate gPDC, generalized partial directed coherence 

% read excel, load signal, select channels, disgard noisy ones, keep the
% good signal 
clear
experiments = get_experiment_redux;
experiments = experiments([68:69]); % what experiments to keep

% loading and filtering variables
fs = 32000; % sampling rate from data
downsampling_factor = 160; % downsample for LFP analysis
fs_LFP = fs / downsampling_factor;
high_cut = fs_LFP / 2; % nyquist frequency: the number of data points per second. Max high cut should be half of sampling frequency
ExtractMode = 1; % extract from neuralynx into matlab
ch2load = 1:48; % select channels to load
cores = 6; 

% save data variables
save_data = 1; 
folder4gpdc = 'Q:\Personal\Tony\Analysis\Results_3Probe_gPDC_coactive\'; 
folder4coactive = 'Q:\Personal\Tony\Analysis\Results_3Probe_Coactive\All3_NoArtifact\';

% sc = [38 42 43 44 37 41 38 42 36];
% sc = [43 41];
% sc = [44 42]; 

% loop through each animal, load signals, and calculate
for exp_idx = 1 : size(experiments, 2)
    % select experiment
    experiment = experiments(exp_idx);
    disp(['Loading LFP for animal number ' num2str(exp_idx)])
    parfor (channel = ch2load, cores)
        disp(['Loading channel ' num2str(channel)]);
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); %origianlly 0.1
        LFP(channel, :) = signal(1 : downsampling_factor : end);
    end
    noisy_channels = experiment.NoisyCh;
    noisy_channels = noisy_channels(ismember(noisy_channels, ch2load));
    LFP(noisy_channels, :) = NaN; %Do the same here for noisy channels. 
    clear signal
    
    % keep only good part of the recording per experiment excel
    if ~ nnz(isnan(experiment.RecKeep))
        experiment.RecKeep = str2num(experiment.RecKeep);
        LFP = LFP(:, experiment.RecKeep(1) * fs_LFP : experiment.RecKeep(2) * fs_LFP);
    end 
    
    LFP1 = nanmedian(LFP(17:32,:)); % PFC 
    LFP2 = nanmedian(LFP(1:16,:)); % Str 
    LFP3 = nanmedian(LFP(33:48,:)); % TH 
    clear LFP 
    
    % optional: select only coactive periods for calculation
    load(strcat(folder4coactive, experiment.animal_ID)); 
    coactive = logical(CoactivePeriods.coactive); 
    LFP1 = LFP1(coactive); 
    LFP2 = LFP2(coactive); 
    LFP3 = LFP3(coactive); 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%     % select single channel signal with CAR 

%     LFP1 = LFP(22,:) - nanmedian(LFP(17:32,:)); % PFC
%     LFP2 = LFP(4,:) - nanmedian(LFP(1:16,:)); % Str
%     LFP3 = LFP(sc(exp_idx),:) - nanmedian(LFP(33:48,:)); % TH
%     clear LFP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%     % section of single channel 
% 
%     file_to_load = [experiment.path, experiment.name, '\CSC22.ncs'];
%     [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
%     signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); %origianlly 0.1
%     LFP1 = signal(1 : downsampling_factor : end);
%     
%     file_to_load = [experiment.path, experiment.name, '\CSC4.ncs'];
%     [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
%     signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); %origianlly 0.1
%     LFP2 = signal(1 : downsampling_factor : end);
%     
%     file_to_load = [experiment.path, experiment.name, '\CSC', num2str(sc(exp_idx)), '.ncs'];
%     [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
%     signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); %origianlly 0.1
%     LFP3 = signal(1 : downsampling_factor : end);
%     clear signal
%     
%     if ~ nnz(isnan(experiment.RecKeep))
%         experiment.RecKeep = str2num(experiment.RecKeep);
%         LFP1 = LFP1(:, experiment.RecKeep(1) * fs_LFP : experiment.RecKeep(2) * fs_LFP);
%         LFP2 = LFP2(:, experiment.RecKeep(1) * fs_LFP : experiment.RecKeep(2) * fs_LFP);
%         LFP3 = LFP3(:, experiment.RecKeep(1) * fs_LFP : experiment.RecKeep(2) * fs_LFP);
%     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    disp(['signal preprocessing for animal number ' num2str(exp_idx) ' done!']);    

    % PFC-Str gPDC
    disp('calculating gPDC 1...')
    tic
    gPDC1 = getGPDC(LFP1, LFP2, fs_LFP, high_cut, experiment.animal_ID, experiment.Area1, experiment.Area2, save_data, folder4gpdc); 
    toc
    
    % Str-TH gPDC 
    disp('calculating gPDC 2...')
    tic
    gPDC2 = getGPDC(LFP2, LFP3, fs_LFP, high_cut, experiment.animal_ID, experiment.Area2, experiment.Area3, save_data, folder4gpdc);  
    toc
    
    % TH-PFC gPDC
    disp('calculating gPDC 3...')
    tic
    gPDC3 = getGPDC(LFP3, LFP1, fs_LFP, high_cut, experiment.animal_ID, experiment.Area3, experiment.Area1, save_data, folder4gpdc);  
    toc
    clear LFP1 LFP2 LFP3
end 


