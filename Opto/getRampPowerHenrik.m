function [StimPowerRamps] = getRampPowerHenrik(experiment, CSC, save_data, repeatCalc, ...
    folderStim, folder2save)

ExtractMode = 2; % for extracting nlx data
fs = 32000; % sampling rate
% ugly fix to define stimulation periods
pre = 1400 : 2800;
first_half = 3000 : 4400;
second_half = 4400 : 5800;
post = 6600 : 8000;
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

if repeatCalc == 0 && exist([folder2save, experiment.animal_ID, '/', num2str(CSC), '.mat'], 'file')
    load([folder2save, experiment.animal_ID, '/', num2str(CSC), '.mat'])
else
    % load stimulation properties
    load([folderStim, experiment.name, '_StimulationProperties_raw'])
    ramps = strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp');
    if nnz(ramps) > 0
        % pre-allocate variables
        Pre = zeros(nnz(ramps), 161);
        Half1 = Pre; Half2 = Pre; Post = Pre;
        % loop over single ramps (no concatenate because of overlap)
        for ramp = 1 : nnz(ramps)
            % set index
            ramp_idx = ramp_idx + 1;
            % define part of signal to load & load it
            % stims are in fs=3.2k, x10 because you are loading in fs=32k
            stimStart = StimulationProperties_raw{ramp, 1}*10 - 3 * fs;
            stimEnd = StimulationProperties_raw{ramp, 2}*10 + 3 * fs;
            % round because indeces
            timepoins_to_load = round([stimStart stimEnd]);
            [~, signal, fs_load] = load_nlx_Modes(file_to_load, ExtractMode, timepoins_to_load);
            % filter & downsample to ms
            signal = ZeroPhaseFilter(signal, fs_load, [2 500]);
            signal = signal(1 : 32 : end);
            % compute all the pWelch stuff
            [Pre(ramp_idx, :) , ~, ~] = pWelchSpectrum(signal(pre), windowSize, ...
                overlap, nfft, pWelch_fs, maxFreq);
            [Half1(ramp_idx, :) , ~, ~] = pWelchSpectrum(signal(first_half), windowSize, ...
                overlap, nfft, pWelch_fs, maxFreq);
            [Half2(ramp_idx, :) , ~, ~] = pWelchSpectrum(signal(second_half), windowSize, ...
                overlap, nfft, pWelch_fs, maxFreq);
            [Post(ramp_idx, :) , freq, ~] = pWelchSpectrum(signal(post), windowSize, ...
                overlap, nfft, pWelch_fs, maxFreq);
        end
        % put everything in a structure
        StimPowerRamps.Half1_sup = Half1;
        StimPowerRamps.Half2_sup = Half2;
        StimPowerRamps.Post_sup = Post;
        StimPowerRamps.Pre_sup = Pre;
        StimPowerRamps.freq = freq;
        if save_data==1
            
            if ~ exist([folder2save, experiment.animal_ID], 'dir')
                mkdir([folder2save, experiment.animal_ID]);
            end
            save([folder2save, experiment.animal_ID, '/', num2str(CSC)], 'StimPowerRamps');
        end
    else
        disp(['no ramps for mouse ' experiment.name])
    end
end
end