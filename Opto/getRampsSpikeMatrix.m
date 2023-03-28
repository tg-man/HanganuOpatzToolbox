function SUAdata = getRampsSpikeMatrix(experiment, save_data, RespArea, ...
    folder4matrix, folder4stim, folder4ramps)

if exist([folder4ramps, RespArea, '/', experiment.name, '.mat'])
    load([folder4ramps, RespArea, '/', experiment.name, '.mat'])
else
    display(['calculating ramp matrix for ', experiment.name])
    % load spike matrix
    load([folder4matrix experiment.name])
    % load stimulation properties
    load([folder4stim experiment.name, '_StimulationProperties_raw.mat']);
    ramps = strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp');
    % ignore if only pulses or baseline
    if nnz(ramps) > 0 && numel(spike_matrix) > 1
        % extract the end of all the ramps
        stim_ends = cat(1, StimulationProperties_raw{ramps,2});
        % convert to ms
        stim_ends = round(stim_ends / 3.2);
        ramp_spike_matrix = zeros(nnz(ramps), size(spike_matrix, 1), 9000); % n_ramps x n_units x time
        % populate the ramp spike matrix one stimulation at a time
        for stim_idx = 1 : nnz(ramps)
            stim_end = stim_ends(stim_idx);
            if stim_end + 3000 > size(spike_matrix, 2)
                stim_end = size(spike_matrix, 2) - 3000;
            end
            if stim_end - 5999 < 0
                ramp_spike_matrix(stim_idx, :, :) = NaN;
                disp('you started the recording after the stimulations!')
            else
                ramp_spike_matrix(stim_idx, :, :) = spike_matrix(:, stim_end - 5999 : stim_end + 3000);
            end
        end
        pre = sum(sum(ramp_spike_matrix(:, :, 1 : 2995), 3)); % light artifact
        during = sum(sum(ramp_spike_matrix(:, :, 3005 : 5995), 3)); % light artifact
        pre_single_ramp = sum(ramp_spike_matrix(:, :, 1 : 2995), 3); % light artifact
        during_single_ramp = sum(ramp_spike_matrix(:, :, 3005 : 5995), 3); % light artifact
        pvalue = zeros(1, length(pre));
        for unit = 1 : length(pre)
            pvalue(unit) = signrank(pre_single_ramp(:, unit), ...
                during_single_ramp(:, unit));
        end
        OMI = (during - pre) ./ (during + pre);
        SUAdata.ramp_spike_matrix = ramp_spike_matrix;
        SUAdata.OMI = OMI;
        SUAdata.pvalue = pvalue;
    else
        SUAdata.ramp_spike_matrix = [];
        SUAdata.OMI = [];
        SUAdata.pvalue = [];
    end
    if save_data == 0
        disp('DATA NOT SAVED!');
    elseif save_data==1
        if ~exist([folder4ramps, RespArea], 'dir')
            mkdir([folder4ramps, RespArea])
        end
        save([folder4ramps RespArea '/' experiment.name], 'SUAdata')        
    end
end
end