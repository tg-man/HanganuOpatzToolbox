function SUAdata_ramp = getRampsSpikeMatrix(experiment, save_data, RespArea, ...
    folder4matrix, folder4stim, folder4ramps)

% with 1s shift, see 

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
        ramp_spike_matrix = zeros(nnz(ramps), size(spike_matrix, 1), 10000); % n_ramps x n_units x time
        % populate the ramp spike matrix one stimulation at a time
        for stim_idx = 1 : nnz(ramps)
            stim_end = stim_ends(stim_idx);
            if stim_end + 4000 > size(spike_matrix, 2)
                stim_end = size(spike_matrix, 2) - 4000;
            end
            if stim_end - 5999 < 0
                ramp_spike_matrix(stim_idx, :, :) = NaN;
                disp('you started the recording after the stimulations!')
            else
                ramp_spike_matrix(stim_idx, :, :) = spike_matrix(:, stim_end - 5999 : stim_end + 4000);
            end
        end
        pre = sum(sum(ramp_spike_matrix(:, :, 1 : 2995), 3)); % light artifact
        during = sum(sum(ramp_spike_matrix(:, :, 4005 : 6995), 3)); % light artifact
        post = sum(sum(ramp_spike_matrix(:, :, 7005: 9995), 3)); % light artifact 
        pre_single_ramp = sum(ramp_spike_matrix(:, :, 1 : 2995), 3); % light artifact
        during_single_ramp = sum(ramp_spike_matrix(:, :, 4005 : 6995), 3); % light artifact
        post_single_ramp = sum(ramp_spike_matrix(:, :, 7005: 9995), 3); % light artifact 
        pvalue = zeros(1, length(pre));
        pvalue_post = zeros(1, length(pre)); 
        for unit = 1 : length(pre)
            pvalue(unit) = signrank(pre_single_ramp(:, unit), during_single_ramp(:, unit));
            pvalue_post(unit) = signrank(pre_single_ramp(:, unit), post_single_ramp(:,unit)); 
        end
        OMI = (during - pre) ./ (during + pre);
        OMI_post = (post - pre) ./ (post + pre); 
        SUAdata_ramp.ramp_spike_matrix = ramp_spike_matrix;
        SUAdata_ramp.OMI = OMI;
        SUAdata_ramp.OMI_post = OMI_post; 
        SUAdata_ramp.pvalue = pvalue;
        SUAdata_ramp.pvalue_post = pvalue_post; 
    else
        SUAdata_ramp.ramp_spike_matrix = [];
        SUAdata_ramp.OMI = [];
        SUAdata_ramp.OMI_post = []; 
        SUAdata_ramp.pvalue = [];
        SUAdata_ramp.pvalue_post = []; 
    end
    if save_data == 0
        disp('DATA NOT SAVED!');
    elseif save_data==1
        if ~exist([folder4ramps, RespArea], 'dir')
            mkdir([folder4ramps, RespArea])
        end
        save([folder4ramps RespArea '/' experiment.name], 'SUAdata_ramp')        
    end
end
end