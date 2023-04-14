function [spikes_tot, animal] = plotPulsesFiringRateHenrik(experiments, RespArea, folder4matrix, folder4stim, folder4pulses)
%% By Mattia

map4plot = viridis(100);
Gwindow = gausswin(1001, 100); % gaussian window of 1000ms with stdev of 10ms
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
save_data = 1;
repeatCalc = 0;
spikes_tot = [];
firing_tot = [];
OMI = [];
pvalue = [];
pre_stim = 40 : 49; % in ms, ramp format
stim = 50 : 59; % in ms, ramp format
idx = 1;

for n_animal = 1 : length(experiments)
    experiment = experiments(n_animal);

    animal{idx} = experiment.animal_ID;
    idx = idx +1;
    PulsesSpikes = getPulsesSpikeMatrix(experiment, save_data, repeatCalc, ...
        folder4matrix, folder4stim, RespArea, folder4pulses); % just loading it now since this is usually calculated before
    spikes_animal = PulsesSpikes.pulse_spike_matrix;
    if ~isnan(spikes_animal)
        % first concatenate the spike tensor into a matrix
        spikes_convolved = reshape(permute(spikes_animal, [2 3 1]), size(spikes_animal, 2), []);
        % convolve it with a gaussian window for better corr estimation
        for unit = 1 : size(spikes_convolved, 1)
            spikes_convolved(unit, :) = conv(spikes_convolved(unit, :), Gwindow, 'same');
        end
        % reshape it back so that you have separated trials
        spikes_convolved = permute(reshape(spikes_convolved, size(spikes_animal, 2), ...
            size(spikes_animal, 3), []), [3 1 2]);
        if numel(spikes_animal) > 0
            if size(spikes_animal, 2) > 1
                spikes_units = squeeze(mean(spikes_animal));
            else
                spikes_units = squeeze(mean(spikes_animal))';
            end
            firing_units(:, 1) = log10(mean(spikes_units(:, pre_stim), 2));
            firing_units(:, 2) = log10(mean(spikes_units(:, stim), 2));
            spikes_tot = cat(1, spikes_tot, spikes_units);
            firing_tot = cat(1, firing_tot, firing_units);
            pre = squeeze(sum(spikes_animal(:, :, pre_stim), 3));
            during = squeeze(sum(spikes_animal(:, :, stim), 3));
            OMI_animal = nanmean((during - pre) ./ (during + pre)); % compute modulation index
            pvalue_animal = zeros(1, size(pre, 2)); % preallocate
            for unit = 1 : size(pre, 2)
                pvalue_animal(unit) = signrank(pre(:, unit), during(:, unit)); % compute pvalue of "modulation index"
            end
            OMI = horzcat(OMI, OMI_animal); % concatenate
            pvalue = horzcat(pvalue, pvalue_animal); % concatenate
            clear firing_units
        end
        clearvars spikes_animal
    end
end

% sort spike trains by similarity but only use "central" part to stress opto differences
zscored_units = zscore(spikes_tot, [], 2); % zscore
idx_sorted = sort_spike_trains(zscored_units);
figure; imagesc(linspace(-125, 125, size(zscored_units, 2)), ...
    1 : size(zscored_units, 1), ...    
    flipud(zscored_units(idx_sorted, :))); colormap(map4plot) % plot
ylabel('Single units'); xlabel('Time (ms)')
set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')

% volcano plot; size is equal to number of spikes and colored upon
% significant or not
RdBu = cbrewer('div', 'RdBu', 100);
num_spikes = sum(spikes_tot, 2); % for size only
num_spikes(num_spikes == 0) = 0.1; % scatter can't handle 0 as an input for size
max_spikes = max(num_spikes);
scaling_factor = 200 / max_spikes;
figure; hold on
scatter(OMI, - log10(pvalue), num_spikes * scaling_factor, pvalue < 0.01, 'filled');
colormap(flip(RdBu)); caxis([-0.1 1.1])
hold on
plot([0 0], get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for no modulation
xlim([-1.1 1.1]); ylim([-0.1 ceil(max(- log10(pvalue)))])
ylabel('- Log10 (pvalue)'); xlabel('Modulation Index'); alpha(0.5)
set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')

modulation = [nnz(OMI < 0 & pvalue < 0.01) ...
    nnz(pvalue > 0.01) nnz(OMI > 0 & pvalue < 0.01)];
modulation = modulation ./ length(OMI);
figure;
bar([modulation; nan(1, length(modulation))], 'stacked')
set(gca,'xtick',1); xlim([0.25 1.75]);
ylabel('Proportion'); xlabel(''); xticks(''); xticklabels('')
title('Proportion of (un)modulated units')
set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')

figure;
boundedline(linspace(-125, 125, size(zscored_units, 2)), mean(zscored_units), std(zscored_units) ./ sqrt(size(zscored_units, 1)))
hold on
plot([0 0], get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
plot([3 3], get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
ylabel('z-scored firing rate (A.U.)'); xlabel('Time (s)'); xlim([-125 125])
title(['SUA firing rate in ' RespArea])
set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
end
