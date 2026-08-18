
% filter experiments 
clear
experiments = get_experiment_redux;
experiments = experiments(557:end);

repeat_calc = 0; 
save_data = 1;

% useful paths 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
folder4eOPN3power = 'Q:\Personal\Tony\Analysis\Results_eOPN3Power\';

% params for signal loading 
params.ExtractMode = 2; % for extracting nlx data
params.fs = 32000; % sampling rate
params.ch2load = 1 : 48; 
params.high_cut = 100; 
params.cores = 4; 
% params baseline loading (in seconds) 
params.bsstart = 25 * 60;
params.bsend = 35 * 60;
% parameters for pWelch
params.windowSize = 1;
params.overlap = 0.4;
params.nfft = 1024;
params.maxFreq = 100;
params.downsample_factor = 32; % from 32k Hz 

% all animals 
mice = unique({experiments.animal_ID});

% loop through each animal to calculate psd 
for mouse_idx = 1 : numel(mice) 
    mouse = mice{mouse_idx}; 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse)); 

    % calculate or overwrite check 
    if ~(repeat_calc == 0 && exist([folder4eOPN3power, mouse, '.mat'], 'file'))

        % loop throug experiments 
        for exp_idx = 1 : numel(exp4mouse)
            experiment = exp4mouse(exp_idx);
            disp(['computing ' num2str(mouse_idx) ' / ' num2str(numel(mice)) ', ' mouse  ', exp ' num2str(exp_idx)])

            % distinguish condition and calculate power accordingly 
            % baseline: calculate a 10min section of the signal 
            if strcmp(experiment.Exp_type, 'baseline only')
                [spectra_baseline, ~] = getPower_eOPN3baseline(experiment, params); 
            % pulses on and off 
            elseif strcmp(experiment.Exp_type, 'opto') && experiment.laserpower > 4
                [spectra_pulses1, spectra_pulses2, ~] = getPower_eOPN3pulses(experiment, folder4stim, params);
            % constant on 
            elseif strcmp(experiment.Exp_type, 'opto') && experiment.laserpower < 3 
                [spectra_constant, freq] = getPower_eOPN3constant(experiment, folder4stim, params);
            end 
        end 
    
        % put everything into a struct 
        eOPN3power.spectra_baseline = spectra_baseline; 
        eOPN3power.spectra_pulses1 = spectra_pulses1; 
        eOPN3power.spectra_pulses2 = spectra_pulses2;
        eOPN3power.spectra_constant = spectra_constant;
        eOPN3power.freq = freq; 

        % save struct 
        if save_data == 1
            if ~ exist(folder4eOPN3power, 'dir')
                mkdir(folder4eOPN3power);
            end
            save([folder4eOPN3power mouse], 'eOPN3power');
        else 
            disp('data not saved!')
        end
    end % repeat calc end 

end 


%% helper function section 

% for pulse and 
function [spectra1, spectra2, freq] = getPower_eOPN3pulses(experiment, folder4stim, params)

% unpack params 
ExtractMode = params.ExtractMode ; % for extracting nlx data
fs = params.fs; % sampling rate
ch2load = params.ch2load; 
cores = params.cores; 
high_cut = params.high_cut; 
% parameters for pWelch
windowSize = params.windowSize;
overlap = params.overlap;
nfft = params.nfft;
maxFreq = params.maxFreq;
downsample_factor = params.downsample_factor;

% load stimualtion properties 
load([folder4stim experiment.name '_StimulationProperties_raw.mat']);
% all time stamps (in miliseconds after division by 3.2)
starts = round(cell2mat(StimulationProperties_raw(:, 1)) * 10);
stops = round(cell2mat(StimulationProperties_raw(:, 2)) * 10);
% find stim breaks 
lightsoff = find(diff(starts) > 4.9 * 60 * fs); % find stim breaks
% time stamps 
start1 = stops(lightsoff(1)); 
stop1 = starts(lightsoff(1) + 1); 
start2 = stops(lightsoff(2));
stop2 = starts(lightsoff(2) + 1); 

% load signal of the 1st pulse break and compute psd 
parfor (channel = ch2load, cores) 
    file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
    [~, signal, fs_load] = load_nlx_Modes(file_to_load, ExtractMode, [start1 stop1]);
    signal = ZeroPhaseFilter(signal, fs_load, [0.5 high_cut]); % origianlly 0.1
    signal = signal(1 : downsample_factor : end); % should be in miliseconds 
    [spectra1(channel, :), ~] = pWelchSpectrum(signal, windowSize, overlap, nfft, fs_load/downsample_factor, maxFreq);
end

% load signal of the 2nd pulse break and compute psd 
parfor (channel = ch2load, cores) 
    file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
    [~, signal, fs_load] = load_nlx_Modes(file_to_load, ExtractMode, [start2 stop2]);
    signal = ZeroPhaseFilter(signal, fs_load, [0.5 high_cut]); % origianlly 0.1
    signal = signal(1 : downsample_factor : end); % should be in miliseconds 
    [spectra2(channel, :), freq(channel, :)] = pWelchSpectrum(signal, windowSize, overlap, nfft, fs_load/downsample_factor, maxFreq);
end
freq = freq(1, :); % to by pass parfor restriction 
    
end % function end 

% for constant on
function [spectra, freq] = getPower_eOPN3constant(experiment, folder4stim, params)

% unpack params 
ExtractMode = params.ExtractMode ; % for extracting nlx data
fs = params.fs; % sampling rate
ch2load = params.ch2load; 
cores = params.cores; 
high_cut = params.high_cut; 
% parameters for pWelch
windowSize = params.windowSize;
overlap = params.overlap;
nfft = params.nfft;
maxFreq = params.maxFreq;
downsample_factor = params.downsample_factor;

% load stimualtion properties 
load([folder4stim experiment.name '_StimulationProperties_raw.mat']);
% all time stamps (in miliseconds after division by 3.2)
start = round(cell2mat(StimulationProperties_raw(:, 1)) * 10);
stop = round(cell2mat(StimulationProperties_raw(:, 2)) * 10);

% load signal of the 1st pulse break and compute psd 
parfor (channel = ch2load, cores) 
    file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
    [~, signal, fs_load] = load_nlx_Modes(file_to_load, ExtractMode, [start stop]);
    signal = ZeroPhaseFilter(signal, fs_load, [0.5 high_cut]); 
    signal = signal(1 : downsample_factor : end); % should be in miliseconds 
    [spectra(channel, :), freq(channel, :)] = pWelchSpectrum(signal, windowSize, overlap, nfft, fs_load/downsample_factor, maxFreq);
end
freq = freq(1, :); % to by pass parfor restriction 

end % function end 

% for baseline 
function [spectra, freq] = getPower_eOPN3baseline(experiment, params)

% unpack params 
ExtractMode = params.ExtractMode ; % for extracting nlx data
fs = params.fs; % sampling rate
ch2load = params.ch2load; 
cores = params.cores; 
high_cut = params.high_cut; 
% for baseline 
bsstart = params.bsstart * fs;
bsend = params.bsend * fs; 
% parameters for pWelch
windowSize = params.windowSize;
overlap = params.overlap;
nfft = params.nfft;
maxFreq = params.maxFreq;
downsample_factor = params.downsample_factor;

% load selected part of baseline signal and compute psd 
parfor (channel = ch2load, cores) 
    file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
    [~, signal, fs_load] = load_nlx_Modes(file_to_load, ExtractMode, [bsstart bsend]);
    signal = ZeroPhaseFilter(signal, fs_load, [0.5 high_cut]); % origianlly 0.1
    signal = signal(1 : downsample_factor : end); % should be in miliseconds 
    [spectra(channel, :), freq(channel, :)] = pWelchSpectrum(signal, windowSize, overlap, nfft, fs_load/downsample_factor, maxFreq);
end
freq = freq(1, :); % to by pass parfor restriction 

end % function end 

