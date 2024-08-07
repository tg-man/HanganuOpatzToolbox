function [spikes_tot, animal] = plotRampFiringRateHenrik(experiments, RespArea, StimArea, folder4matrix, folder4stim, folder4ramps)
%% By Mattia

% This function only cares about if a stim is given BUT NOT WHERE a stim is
% given. So this should be selected beforehand

map4plot = viridis(100);
Gwindow = gausswin(1001, 10); % gaussian window of 1000ms with stdev of 100ms
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
save_data = 1;
spikes_tot = [];
OMI = [];
OMIpost = [];
pvalue = [];
pvalue_post = [];
pre_stim = 1 : 3000; % in ms, ramp format
stim = 3001 : 6000; % in ms, ramp format
post_stim = 6001 : 9000; % in ms, ramp format
idx = 1;

% this loop goes through all experiments and calculate the standard OMI and
% test for significance 
for n_animal = 1 : length(experiments)
    experiment = experiments(n_animal);
    animal{idx} = experiment.animal_ID;
    idx = idx +1;
    SUAdata = getRampsSpikeMatrix(experiment, save_data, 0, RespArea, ...
        folder4matrix, folder4stim, folder4ramps);
    spikes_animal = SUAdata.ramp_spike_matrix;
    
    % convolution part, not used as of now 
%     % first concatenate the spike tensor into a matrix
%     spikes_convolved = reshape(permute(spikes_animal, [2 3 1]), size(spikes_animal, 2), []);
%     % convolve it with a gaussian window for better corr estimation
%     for unit = 1 : size(spikes_convolved, 1)
%         spikes_convolved(unit, :) = conv(spikes_convolved(unit, :), Gwindow, 'same');
%     end
%     % reshape it back so that you have separated trials
%     spikes_convolved = permute(reshape(spikes_convolved, size(spikes_animal, 2), ...
%         size(spikes_animal, 3), []), [3 1 2]);

    if numel(spikes_animal) > 0
        if size(spikes_animal, 2) > 1
            spikes_units = squeeze(mean(spikes_animal));
        else
            spikes_units = squeeze(mean(spikes_animal))';
        end
        spikes_tot = cat(1, spikes_tot, spikes_units);
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
    end
    clearvars spikes_animal
end

% sort of raster map like github mouseland
spikes_reduced = squeeze(mean(reshape(spikes_tot, size(spikes_tot, 1), 100, []), 2)); % lin alg trick to downsample to save time: chop up, reshape into three dimensions, squeeze the new dimension
% sort spike trains by similarity but only use "central" part to stress opto differences
zscored_units = zscore(spikes_reduced, [], 2); % zscore
idx_sorted = sort_spike_trains(zscored_units);
figure; imagesc(flipud(zscored_units(idx_sorted, :)), [-1 3]); colormap(map4plot); % plot
hold on
plot([size(spikes_reduced, 2) / 10 * 3 size(spikes_reduced, 2) / 10 * 3], ...
    get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
plot([size(spikes_reduced, 2) / 10 * 6 size(spikes_reduced, 2) / 10 * 6], ...
    get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
ylabel('Single units');
xticks([30 60 90]); xticklabels({3 6 9}); xlabel('Time (s)')
set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
title([RespArea ' units to ' StimArea ' stim'])

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
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2)
title([RespArea ' units to ' StimArea ' stim'])

% volcano plot; size is equal to number of spikes and colored upon
% significant or not
RdBu = cbrewer('div', 'RdBu', 100);
num_spikes = sum(spikes_tot, 2); % for size only
num_spikes(num_spikes == 0) = 0.1; % scatter can't handle 0 as an input for size
max_spikes = max(num_spikes);
scaling_factor = 200 / max_spikes;
figure; hold on
scatter(OMIpost, - log10(pvalue_post), num_spikes * scaling_factor, pvalue_post < 0.01, 'filled');
colormap(flip(RdBu)); caxis([-0.1 1.1])
hold on
plot([0 0], get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for no modulation
xlim([-1.1 1.1]); ylim([-0.1 ceil(max(- log10(pvalue_post)))])
ylabel('- Log10 (pvalue)'); xlabel('Post Modulation Index'); alpha(0.5)
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2)
title([RespArea ' units post ' StimArea ' stim'])

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
boundedline(linspace(0, 10, size(zscored_units, 2)), mean(zscored_units), std(zscored_units) ./ sqrt(size(zscored_units, 1)))
hold on
xline(3, ':k', 'linewidth', 1.5) % reference line for opto
xline(6, ':k', 'linewidth', 1.5) % reference line for opto
ylabel('z-scored firing rate (A.U.)'); xlabel('Time (s)'); xlim([0 10])
title(['SUA firing rate in ' RespArea ' to ' StimArea ' Stim'])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2)
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end

figure;
boundedline(linspace(0, 10, size(spikes_reduced, 2)), mean(spikes_reduced), std(spikes_reduced) ./ sqrt(size(spikes_reduced, 1))); 
hold on
xline(3, ':k', 'linewidth', 1.5) % reference line for opto
xline(6, ':k', 'linewidth', 1.5) % reference line for opto
ylabel('average FR (Hz)'); xlabel('Time (s)'); xlim([0 10]); 
%ylim([0 0.0006])
title(['SUA FR in ' RespArea ' to ' StimArea ' Stim'])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2)
set(gca, 'YScale', 'log'); 
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end



end
