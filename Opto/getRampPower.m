function [StimPowerRamps] = getRampPower(experiment, CSC, save_data, params, repeatCalc, folderStim, folder2save)
% Adapted from Mattia's scripts originally written for Henrik 

% unpack params 
ExtractMode = params.ExtractMode ; % for extracting nlx data
fs = params.fs; % sampling rate
pre = params.pre;
first_half = params.first_half;
second_half = params.second_half;
post = params.post;
% parameters for pWelch
windowSize = params.windowSize;
overlap = params.overlap;
nfft = params.nfft;
maxFreq = params.maxFreq;
downsample_factor = params.downsample_factor;

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
%         % pre-allocate variables
%         Pre = zeros(size(StimulationProperties_raw,1), 161);
%         Half1 = Pre; Half2 = Pre; Post = Pre;
        % loop over single ramps (no concatenate because of overlap)
        for ramp = 1 : size(StimulationProperties_raw,1)
            % loaded here 4s before and 5s after the ramp       
            % stims are in fs=3.2k, x10 because you are loading in fs=32k
            stimStart = StimulationProperties_raw{ramp, 1}*10 - 4 * fs;
            stimEnd = StimulationProperties_raw{ramp, 2}*10 + 5 * fs;
            % round because indeces
            timepoins_to_load = round([stimStart stimEnd]);
            % loading signal 
            [~, signal, fs_load] = load_nlx_Modes(file_to_load, ExtractMode, timepoins_to_load);
            % filter & downsample to ms
            signal = ZeroPhaseFilter(signal, fs_load, [2 500]);
            signal = signal(1 : downsample_factor : end);
            % compute all the pWelch stuff
            [Pre(ramp, :) , ~] = pWelchSpectrum(signal(pre), windowSize, overlap, nfft, fs_load/downsample_factor, maxFreq);
            [Half1(ramp, :) , ~] = pWelchSpectrum(signal(first_half), windowSize, overlap, nfft, fs_load/downsample_factor, maxFreq);
            [Half2(ramp, :) , ~] = pWelchSpectrum(signal(second_half), windowSize, overlap, nfft, fs_load/downsample_factor, maxFreq);
            [Post(ramp, :) , freq] = pWelchSpectrum(signal(post), windowSize, overlap, nfft, fs_load/downsample_factor, maxFreq);
        end
        % put everything in a structure
        StimPowerRamps.Half1 = Half1;
        StimPowerRamps.Half2 = Half2;
        StimPowerRamps.Post = Post;
        StimPowerRamps.Pre = Pre;
        StimPowerRamps.freq = freq;
        % save 
        if save_data==1
            if ~ exist([folder2save, experiment.name], 'dir')
                mkdir([folder2save, experiment.name]);
            end
            save([folder2save, experiment.name, '/', num2str(CSC)], 'StimPowerRamps');
        end
    else
        disp(['no ramps for mouse ' experiment.name])
    end
end
end