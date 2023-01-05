%% load experiment info and set a few variables for analysis

clear
% load experiments and generic stuff
experiments = get_experiment_redux;
experiments = experiments(); 
repeatCalc = 0;
save_data = 1;
% the number of CPU cores to use to load signal. Unless you are doing
% nothing else on your computer, do not use all of them. Otherwise you will
% end with no processing power for anything else


% loading and filtering variables
fs = 32000; % from data
downsampling_factor = 100; % downsample for LFP analysis
fs_LFP = fs / downsampling_factor;
high_cut = fs / downsampling_factor / 2; % nyquist
ExtractMode = 1; % extract from neuralynx into matlab

% coherence variables
win_length = 4; % window length for coherence (in seconds)
% window overlap for coherence (in seconds)
iterations = 4; 
PlotFlag = 0; 

folder4SUA = 'D:\for_Tony\SUA_info\Str\';

%% 
getCoherence(spkTimes,inputSignal,Fs,windowSize,iterations,plotFlag)

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    
    %load SUA info 
    load(strcat(folder4SUA, experiment.animal_ID)); %load SUAinfo

    % load signal and filter for LFP
    disp(['loading LFP for animal number ' num2str(exp_idx)])
    parfor (channel = 17:32, cores) %PFC signal
        if ismember(channel, experiment.NoisyCh) == 1
            LFP(channel - 16,:) = NaN;
        else
            file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
            disp(['loading channel ' num2str(channel)])
            [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
            signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); %original lowcut 0
            LFP(channel - 16, :) = signal(1 : downsampling_factor : end);
        end 
    end
    
    %load and downsample spike timing
    load(strcat(folder4SUA, experiments.animal_ID)); 
    for i = 1:size(SUAinfo{1, 1},2)
        for j = 1: SUAinfo(i).Timestamps 
            ST(j) = SUAinfo(i).Timestamps(j,1)/100; 
            
        end 
    end 
    
    
    
    clear SUAinfo
    clear LFP 
end