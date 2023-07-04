function SUAdata_pulses = getPulsesSpikeMatrix_old(experiment, save_data, repeatCalc, ...
    pulse_length, folder4matrix, folder4stim, respArea, folder2save)
% by Mattia 10/22 further adapted by Tony Apr.2023

% create a spike matrix (actually a tensor) for pulses stimulations
% this script creates a matrix of 250ms centered around the pulse start and 
% consideres a window (equal length to the pulse stim) for pre, stim, and post periods 
% in which to count spikes to determine if the unit is responding or not. 
% Pre period ends 3ms before the pulse start. This value is adopted from
% previous scirpt but essentially arbitrary (they are not set in stone!).

% inputs:       - experiment: the usual structure (will be used for loading
%                             and saving
%               - save_data: binary
%               - repeatCalc: binary
%               - pulse_length: [vector, length of pulses given, in SECONDS, comma separated]
%               - folder2save: string - where to save results
%               - folderSM: folder where spike matrices are saved
%               - folder4stim_props: folder containing info about
%                                    stimulation properties in our usual
%                                    format
% output:       - SUAdata: structure with spike matrix, modulation index
%                          and respective pvalue

if exist([folder2save respArea '\' experiment.name '.mat'], ...
        'file') && repeatCalc == 0
    load([folder2save respArea '\' experiment.name '.mat'])
else
    display(['calculating pulse matrix for ', experiment.name])
    % load SUA spike matrix
    load([folder4matrix experiment.name])
    % load stimulation properties
    load([folder4stim experiment.name '_StimulationProperties_raw'])
    % extract info about pulses
    PulsesInfo = StimulationProperties_raw(strcmp(StimulationProperties_raw(:, 8), 'constant'), :);
    if ~ isempty(PulsesInfo) && numel(spike_matrix) > 1
        % these are in timestamps, convert them to ms
        PulseStart = round(cat(1, PulsesInfo{:, 9})) / 3.2;
        % initialize matrix (n_pulses x n_units x time)
        pulses_spike_matrix = zeros(numel(PulseStart), size(spike_matrix, 1), 250);
        % allocate spike matrix pulse-by-pulse sweep
        for stim_idx = 1 : numel(PulseStart)
            stim_period = round(PulseStart(stim_idx) - 250 : PulseStart(stim_idx) + 1500); % timestamps in ms for 250ms around the pulse start 
            if max(stim_period) > size(spike_matrix, 2)
                pulses_spike_matrix(stim_idx, :, :) = 0;
                disp(['pulse ' num2str(stim_idx) ' filled with 0 because there are no spikes in the spike matrix'])
            else
                pulses_spike_matrix(stim_idx, :, :) = spike_matrix(:, stim_period);
            end
        end
        % extract duration of pulses and correct pulse duration to the set input values 
        PulseDur = cat(1, PulsesInfo{:, 5}); 
        for trial_idx = 1 : size(PulseDur, 1)
            PulseDur(trial_idx) = pulse_length(round(PulseDur(trial_idx)./ pulse_length) == 1);
        end 
        % separate opto matrices by pulse duration 
        for dur_idx = 1 : numel(pulse_length)
            temp_mat{dur_idx} = pulses_spike_matrix(PulseDur == pulse_length(dur_idx),:,:); 
            stim_time{dur_idx} = 126: (125 + pulse_length(dur_idx)*1000);
            pre_time{dur_idx} = stim_time{dur_idx} - length(stim_time{dur_idx}) - 3; % stop at 3 ms before the pulse
            post_time{dur_idx} = stim_time{dur_idx} + length(stim_time{dur_idx}) + 3;
        end 
        pulses_spike_matrix = temp_mat; 
        clear temp_mat; 
        % compute spikes in pre-during-post periods
        for dur_idx = 1 : numel(pulse_length) 
            pre{dur_idx} = sum(sum(pulses_spike_matrix{dur_idx}(:, :, pre_time{dur_idx}), 3)); 
            during{dur_idx} = sum(sum(pulses_spike_matrix{dur_idx}(:, :, stim_time{dur_idx}), 3)); 
            post{dur_idx} = sum(sum(pulses_spike_matrix{dur_idx}(:, :, post_time{dur_idx}), 3)); 
            pre_single_pulses{dur_idx} = sum(pulses_spike_matrix{dur_idx}(:, :, pre_time{dur_idx}), 3); 
            during_single_pulses{dur_idx} = sum(pulses_spike_matrix{dur_idx}(:, :, stim_time{dur_idx}), 3);
            post_single_pulses{dur_idx} = sum(pulses_spike_matrix{dur_idx}(:, :, post_time{dur_idx}), 3);    
        end 
        % compute simple paired rank-sum test, looping through each pulse
        % duration and unit
        pvalue = zeros(numel(pulse_length), size(spike_matrix,1)); % initialize pvalue, n_pulse_length X n_cells 
        pvalue_post = zeros(numel(pulse_length), size(spike_matrix,1));
        for dur_idx = 1 : numel(pulse_length)
            for unit = 1 : length(pre)
                pvalue(dur_idx, unit) = signrank(pre_single_pulses{dur_idx}(:, unit), during_single_pulses{dur_idx}(:, unit));
                pvalue_post(dur_idx, unit) = signrank(pre_single_pulses{dur_idx}(:, unit), post_single_pulses{dur_idx}(:, unit));
            end
        end 
        % compute OMI and OMI post, looping through each duration 
        OMI = zeros(numel(pulse_length), size(spike_matrix,1)); %initialize OMI, n_pulse_length X n_cells 
        OMI_post = zeros(numel(pulse_length), size(spike_matrix,1));
        for dur_idx = 1 : numel(pulse_length)
            OMI(dur_idx,:) = (during{dur_idx} - pre{dur_idx}) ./ (during{dur_idx} + pre{dur_idx});
            OMI_post(dur_idx,:) = (post{dur_idx} - pre{dur_idx}) ./ (post{dur_idx} + pre{dur_idx});
        end 
        
        % put everything in a structure
        SUAdata_pulses.pulse_spike_matrix = pulses_spike_matrix;
        SUAdata_pulses.OMI = OMI;
        SUAdata_pulses.OMI_post = OMI_post; 
        SUAdata_pulses.pvalue = pvalue;
        SUAdata_pulses.pvalue_post = pvalue_post;
        SUAdata_pulses.pulses = pulse_length;
    else
        OMI = NaN;
        SUAdata_pulses.pulse_spike_matrix = NaN;
        SUAdata_pulses.OMI = NaN;
        SUAdata_pulses.pvalue = NaN;
    end
    if save_data == 1
        if ~ exist([folder2save respArea])
            mkdir([folder2save respArea]);
        end
        save([folder2save respArea '\' experiment.name], 'SUAdata_pulses')
    end
end


