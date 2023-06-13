function [timepoins_to_load] = plotRampSignal(experiment, CSC, save_data, repeatCalc, ...
    folderStim, folder2save)

% Adapted from Mattia's scripts originally written for Henrik 

ExtractMode = 2; % for extracting nlx data
fs = 32000; % sampling rate
% define period in ms; time stamps can change depending on signal loading.
% Refer to line #45
pre = 2500 : 4000;
first_half = 4000 : 5500;
second_half = 5500 : 7000;
post = 7500 : 9000;
% parameters for pWelch
windowSize = 1;
overlap = 0.4;
nfft = 800;
maxFreq = 200;
pWelch_fs = 1000;
% extract ramp info
ramp_idx = 0;
% file to load
file_to_load = strcat(experiment.path, experiment.name, filesep, 'CSC', num2str(CSC), '.ncs');

if repeatCalc == 0 && exist([folder2save, experiment.name, '/', num2str(CSC), '.mat'], 'file')
    load([folder2save, experiment.name, '/', num2str(CSC), '.mat'])
else
    % load stimulation properties
    load([folderStim, experiment.name, '_StimulationProperties_raw'])
    ramps = strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp');
    % select only proper ramp stims
    StimulationProperties_raw = StimulationProperties_raw(ramps, :); 
    StimulationProperties_raw = StimulationProperties_raw(round(cell2mat(StimulationProperties_raw(:, 5))) == 3, :); 
    if size(StimulationProperties_raw,1) > 0
        % pre-allocate variables
        Pre = zeros(size(StimulationProperties_raw,1), 161);
        Half1 = Pre; Half2 = Pre; Post = Pre;
        % loop over single ramps (no concatenate because of overlap)
        ramp = 10; 
        % define part of signal to load & load it
        % stims are in fs=3.2k, x10 because you are loading in fs=32k
        % loaded here 4s before and 5s after the ramp
        stimStart = StimulationProperties_raw{ramp, 1}*10 - 4 * fs;
        stimEnd = StimulationProperties_raw{ramp, 2}*10 + 5 * fs;
        % round because indeces
        timepoins_to_load = round([stimStart stimEnd]);
        % loading signal 
        [~, signal, fs_load] = load_nlx_Modes(file_to_load, ExtractMode, timepoins_to_load);
        % filter & downsample to ms
        signal = ZeroPhaseFilter(signal, fs_load, [2 500]);
        signal = signal(1 : 32 : end);
        % plot the signal 
        figure; plot(signal); 
        title([ experiment.name, ' Ch ', num2str(CSC)]); 
        ylim([-200 200]); xlim([1 12000])
        xline(4000); xline(7000); 
    else
        disp(['no ramps for mouse ' experiment.name])
    end
end
end