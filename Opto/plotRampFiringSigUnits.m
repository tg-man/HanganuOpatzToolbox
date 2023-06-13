function [spikes_tot, animal] = plotRampFiringSigUnits(experiments, RespArea, StimArea, folder4matrix, folder4stim, folder4ramps)
%% By Mattia

% This function only cares about if a stim is given BUT NOT WHERE a stim is
% given. So this should be selected beforehand

map4plot = viridis(100);
Gwindow = gausswin(1001, 10); % gaussian window of 1000ms with stdev of 100ms
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
save_data = 1;
spikes_tot = [];
firing_tot = [];
OMI = [];
OMIpost = [];
pvalue = [];
pvalue_post = [];
pre_stim = 1 : 3000; % in ms, ramp format
stim = 4000 : 7000; % in ms, ramp format
post_stim = 7001 : 9000; % in ms, ramp format
idx = 1;

% this loop goes through all experiments and calculate the standard OMI and
% test for significance 
for n_animal = 1 : length(experiments)
    experiment = experiments(n_animal);
    animal{idx} = experiment.animal_ID;
    idx = idx +1;
    SUAdata = getRampsSpikeMatrix(experiment, save_data, RespArea, ...
        folder4matrix, folder4stim, folder4ramps);
    spikes_animal = SUAdata.ramp_spike_matrix;
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
        firing_units(:, 3) = log10(mean(spikes_units(:, post_stim), 2));
        spikes_tot = cat(1, spikes_tot, spikes_units);
        firing_tot = cat(1, firing_tot, firing_units);
        pre = squeeze(sum(spikes_animal(:, :, pre_stim), 3)); % summing up all the spikes in pre_stim period
        during = squeeze(sum(spikes_animal(:, :, stim), 3));
        post = squeeze(sum(spikes_animal(:, :, post_stim), 3));
        OMI_animal = nanmean((during - pre) ./ (during + pre)); % compute modulation index
        OMI_animal_post = nanmean((post - pre) ./ (post + pre)); % compute modulation index
        pvalue_animal = zeros(1, size(pre, 2)); % preallocate
        pvalue_animal_post = zeros(1, size(pre, 2)); % preallocate
        for unit = 1 : size(pre, 2)
            pvalue_animal(unit) = signrank(pre(:, unit), during(:, unit)); % compute pvalue of "modulation index"
            pvalue_animal_post(unit) = signrank(pre(:, unit), post(:, unit)); % compute pvalue of "modulation index"
        end
        OMI = horzcat(OMI, OMI_animal); % concatenate
        pvalue = horzcat(pvalue, pvalue_animal); % concatenate
        OMIpost = horzcat(OMIpost, OMI_animal_post); % concatenate
        pvalue_post = horzcat(pvalue_post, pvalue_animal_post); % concatenate
        clear firing_units
    end
    clearvars spikes_animal
end

% sort of raster map like github mouseland
spikes_sig = spikes_tot(pvalue < 0.01, :); % take only significant units 
spikes_reduced = squeeze(mean(reshape(spikes_sig, size(spikes_sig, 1), 100, []), 2)); % lin alg trick to downsample to save time: chop up, reshape into three dimensions, squeeze the new dimension
% sort spike trains by similarity but only use "central" part to stress opto differences
zscored_units = zscore(spikes_reduced, [], 2); % zscore
idx_sorted = sort_spike_trains(zscored_units);
figure; imagesc(flipud(zscored_units(idx_sorted, :)), [-1 3]); colormap(map4plot) % plot
hold on
plot([size(spikes_reduced, 2) / 9 * 3 size(spikes_reduced, 2) / 9 * 3], ...
    get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
plot([size(spikes_reduced, 2) / 9 * 6 size(spikes_reduced, 2) / 9 * 6], ...
    get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
ylabel('Single units'); xlabel('Time (x100ms)')
set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
title([RespArea ' sig units to ' StimArea ' stim'])

% line plot of average firing rate of sig unites 
figure;
boundedline(linspace(0, 9, size(zscored_units, 2)), mean(zscored_units), std(zscored_units) ./ sqrt(size(zscored_units, 1)))
hold on
plot([3 3], get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
plot([6 6], get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
ylabel('z-scored firing rate (A.U.)'); xlabel('Time (s)'); xlim([0 9])
title(['SUA firing rate in ' RespArea ' to ' StimArea ' Stim'])
set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')

end
