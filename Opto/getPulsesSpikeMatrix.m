function SUAdata_pulses = getPulsesSpikeMatrix(experiment, save_data, repeatCalc, ...
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


if exist([folder2save respArea '\' experiment.name '.mat'], 'file') && repeatCalc == 0
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
        PulseStart = round((cat(1, PulsesInfo{:, 9})) / 3.2);
        % initialize matrix (n_pulses x n_units x time)
        pulses_spike_matrix = zeros(numel(PulseStart), size(spike_matrix, 1), 1500);
        % allocate spike matrix pulse-by-pulse sweep
        for stim_idx = 1 : numel(PulseStart)
            stim_period = round(PulseStart(stim_idx) - 499 : PulseStart(stim_idx) + 1000); % timestamps in ms for 250ms around the pulse start 
            if max(stim_period) > size(spike_matrix, 2)
                pulses_spike_matrix(stim_idx, :, :) = 0;
                disp(['pulse ' num2str(stim_idx) ' filled with 0 because there are no spikes in the spike matrix'])
            else
                pulses_spike_matrix(stim_idx, :, :) = spike_matrix(:, stim_period);
            end
        end
        
        % separate pulses spike matrix based on pulse duration 
        if numel(pulse_length) == 3
            SUAdata_pulses.pulse_spike_matrix5 = pulses_spike_matrix(ceil(cell2mat(PulsesInfo(:, 5))*1000) == 5, :, :); 
            SUAdata_pulses.pulse_spike_matrix15 = pulses_spike_matrix(ceil(cell2mat(PulsesInfo(:, 5))*1000) == 15, :, :); 
            SUAdata_pulses.pulse_spike_matrix50 = pulses_spike_matrix(ceil(cell2mat(PulsesInfo(:, 5))*1000) == 50, :, :); 
        elseif numel(pulse_length) == 2 
            SUAdata_pulses.pulse_spike_matrix15 = pulses_spike_matrix(ceil(cell2mat(PulsesInfo(:, 5))*1000) == 15, :, :); 
            SUAdata_pulses.pulse_spike_matrix50 = pulses_spike_matrix(ceil(cell2mat(PulsesInfo(:, 5))*1000) == 50, :, :);           
        end     
    end
    
    SUAdata_pulses.pulse_length = pulse_length; 
      
    if save_data == 1
        if ~ exist([folder2save respArea])
            mkdir([folder2save respArea]);
        end
        save([folder2save respArea '\' experiment.name], 'SUAdata_pulses')
    end
    
end 

end