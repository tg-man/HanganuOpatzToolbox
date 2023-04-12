function SUAdata_pulses = getPulsesSpikeMatrix(experiment, save_data, repeatCalc, ...
    folder4matrix, folder4stim, respArea, folder2save)
% by Mattia 10/22 adapted from the version in the Seq project

% divide the 100ms stim period in pre (40-50) stim (51-60)
pre_time = 40 : 47;
stim_time = 51 : 58;

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
            stim_period = round(PulseStart(stim_idx) - 124 : PulseStart(stim_idx) + 125);
            if max(stim_period) > size(spike_matrix, 2)
                pulses_spike_matrix(stim_idx, :, :) = 0;
                disp(['pulse ' num2str(stim_idx) ' filled with 0 because there are no spikes in the spike matrix'])
            else
                pulses_spike_matrix(stim_idx, :, :) = spike_matrix(:, stim_period);
            end
        end
        % compute spikes in pre-during-post periods
        pre = sum(sum(pulses_spike_matrix(:, :, pre_time), 3)); % light artifact
        during = sum(sum(pulses_spike_matrix(:, :, stim_time), 3)); % light artifact
        pre_single_pulses = sum(pulses_spike_matrix(:, :, pre_time), 3); % light artifact
        during_single_pulses = sum(pulses_spike_matrix(:, :, stim_time), 3); % light artifact
        % compute simple paired rank-sum test
        pvalue = zeros(1, length(pre));
        for unit = 1 : length(pre)
            pvalue(unit) = signrank(pre_single_pulses(:, unit), ...
                during_single_pulses(:, unit));
        end
        % put everything in a structure
        OMI = (during - pre) ./ (during + pre);
        SUAdata_pulses.pulse_spike_matrix = pulses_spike_matrix;
        SUAdata_pulses.OMI = OMI;
        SUAdata_pulses.pvalue = pvalue;
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