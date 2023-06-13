function [spikes_tot, animal] = plotPulsesFiringRateHenrik(experiments, RespArea, StimArea, pulse_length, folder4matrix, folder4stim, folder4pulses)
%% By Mattia

map4plot = viridis(100);
Gwindow = gausswin(1001, 100); % gaussian window of 1000ms with stdev of 10ms
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
save_data = 1;
repeatCalc = 0;
spikes_tot = cell(1, numel(pulse_length));
firing_tot = cell(1, numel(pulse_length));
OMI = cell(1, numel(pulse_length));
pvalue = cell(1, numel(pulse_length));
idx = 1;

for n_animal = 1 : length(experiments)
    experiment = experiments(n_animal);

    animal{idx} = experiment.animal_ID;
    idx = idx +1;
    PulsesSpikes = getPulsesSpikeMatrix(experiment, save_data, repeatCalc, ...
        pulse_length, folder4matrix, folder4stim, RespArea, folder4pulses); % just loading it now since this is usually calculated before
    spikes_animal = PulsesSpikes.pulse_spike_matrix;
    
    % looping through each pulse duration and compute stuff 
    for stim_idx = 1 : numel(pulse_length)
        
        % define pre stim and stim period of the same length. Stim starts at 126 in the spike matrices 
        pre_stim = (122 - pulse_length(stim_idx)*1000) : 122; % in ms
        stim = 127 : (125 + pulse_length(stim_idx)*1000); % in ms
        
        if ~isnan(spikes_animal{1,stim_idx})
            % first concatenate the spike tensor into a matrix
            spikes_convolved = reshape(permute(spikes_animal{1,stim_idx}, [2 3 1]), size(spikes_animal{1,stim_idx}, 2), []);
            % convolve it with a gaussian window for better corr estimation
            for unit = 1 : size(spikes_convolved, 1)
                spikes_convolved(unit, :) = conv(spikes_convolved(unit, :), Gwindow, 'same');
            end
            % reshape it back so that you have separated trials
            spikes_convolved = permute(reshape(spikes_convolved, size(spikes_animal{1,stim_idx}, 2), ...
                size(spikes_animal{1,stim_idx}, 3), []), [3 1 2]);
            
            if numel(spikes_animal{1,stim_idx}) > 0
                if size(spikes_animal{1,stim_idx}, 2) > 1
                    spikes_units{1,stim_idx} = squeeze(mean(spikes_animal{1,stim_idx}));
                else
                    spikes_units{1,stim_idx} = squeeze(mean(spikes_animal{1,stim_idx}))';
                end
                firing_units(:, 1) = log10(mean(spikes_units{1,stim_idx}(:, pre_stim), 2));
                firing_units(:, 2) = log10(mean(spikes_units{1,stim_idx}(:, stim), 2));
                spikes_tot{1,stim_idx} = cat(1, spikes_tot{1,stim_idx}, spikes_units{1,stim_idx});
                firing_tot{1,stim_idx} = cat(1, firing_tot{1,stim_idx}, firing_units);
                pre = squeeze(sum(spikes_animal{1,stim_idx}(:, :, pre_stim), 3));  %%%
                during = squeeze(sum(spikes_animal{1,stim_idx}(:, :, stim), 3));   %%%
                OMI_animal = nanmean((during - pre) ./ (during + pre)); % compute modulation index
                pvalue_animal{1,stim_idx} = zeros(1, size(pre, 2)); % preallocate
                for unit = 1 : size(pre, 2)
                    pvalue_animal{1,stim_idx}(unit) = signrank(pre(:, unit), during(:, unit)); % compute pvalue of "modulation index"
                end
                OMI{1,stim_idx} = horzcat(OMI{1,stim_idx}, OMI_animal); % concatenate
                pvalue{1,stim_idx} = horzcat(pvalue{1,stim_idx}, pvalue_animal{1,stim_idx}); % concatenate
                clear firing_units
            end
        end
    end 
    clearvars spikes_animal
end

% sort spike trains by similarity but only use "central" part to stress opto differences

for stim_idx = 1 : numel(pulse_length)
    pulse = pulse_length(stim_idx); 
    zscored_units{1,stim_idx} = zscore(spikes_tot{1,stim_idx}, [], 2); % zscore
    idx_sorted{1,stim_idx} = sort_spike_trains(zscored_units{1,stim_idx});
    figure; imagesc(linspace(-125, 125, size(zscored_units{1,stim_idx}, 2)), ...
        1 : size(zscored_units{1,stim_idx}, 1), ...    
        flipud(zscored_units{1,stim_idx}(idx_sorted{1,stim_idx}, :))); colormap(map4plot) % plot
    xline(pulse*1000); xline(0); 
    ylabel('Single units'); xlabel('Time (ms)')
    title([RespArea ' to ' StimArea ' stim ' num2str(pulse*1000) 'ms'])
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
end 

% volcano plot; size is equal to number of spikes and colored uponsignificant or not
for stim_idx = 1 : numel(pulse_length)
    pulse = pulse_length(stim_idx); 
    RdBu = cbrewer('div', 'RdBu', 100);
    num_spikes = sum(spikes_tot{1,stim_idx}, 2); % for size only
    num_spikes(num_spikes == 0) = 0.1; % scatter can't handle 0 as an input for size
    max_spikes = max(num_spikes);
    scaling_factor = 200 / max_spikes;
    figure; hold on
    scatter(OMI{1,stim_idx}, - log10(pvalue{1,stim_idx}), num_spikes * scaling_factor, pvalue{1,stim_idx} < 0.01, 'filled');
    colormap(flip(RdBu)); caxis([-0.1 1.1])
    hold on
    plot([0 0], get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for no modulation
    xlim([-1.1 1.1]); ylim([-0.1 ceil(max(- log10(pvalue{1,stim_idx})))])
    ylabel('- Log10 (pvalue)'); xlabel('Modulation Index'); alpha(0.5)
    title([RespArea ' to ' StimArea ' stim ' num2str(pulse*1000) 'ms'])
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')

end 

% bar plot of modulated unit proportion 
for stim_idx = 1 : numel(pulse_length)
    pulse = pulse_length(stim_idx); 
    modulation = [nnz(OMI{1,stim_idx} < 0 & pvalue{1,stim_idx} < 0.01) ...
        nnz(pvalue{1,stim_idx} > 0.01) nnz(OMI{1,stim_idx} > 0 & pvalue{1,stim_idx} < 0.01)];
    modulation = modulation ./ length(OMI{1,stim_idx});
    figure;
    bar([modulation; nan(1, length(modulation))], 'stacked')
    set(gca,'xtick',1); xlim([0.25 1.75]);
    ylabel('Proportion'); xlabel(''); xticks(''); xticklabels('')
    title([RespArea ' to ' StimArea ' stim ' num2str(pulse*1000) 'ms'])
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
end 

% population vector 
for stim_idx = 1 : numel(pulse_length)
    pulse = pulse_length(stim_idx); 
    figure;
    boundedline(linspace(-125, 125, size(zscored_units{1,stim_idx}, 2)), mean(zscored_units{1,stim_idx}), std(zscored_units{1,stim_idx}) ./ sqrt(size(zscored_units{1,stim_idx}, 1)))
    hold on
    xline(pulse*1000, 'k', 'linewidth', 1); % opto reference line 
    xline(0,  'k', 'linewidth', 1); % opto reference line 
    ylabel('z-scored firing rate (A.U.)'); xlabel('Time (s)'); xlim([-125 125])
    title(['SUA firing rate in ' RespArea ' to ' StimArea ' stim ' num2str(pulse*1000) 'ms'])
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
end 

end
