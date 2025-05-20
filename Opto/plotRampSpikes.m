function [spikes_tot, allcells, mice, age] = plotRampSpikes(experiments, area, folder4matrix, folder4ramps)
% Tony, May 2025 
% filter stim type before entering the function! 

spikes_tot = [];
condition = []; 
age = []; 
allcells = []; 
mice = []; 
OMI = []; 
pvalue = []; 
OMIpost = []; 
pvalue_post = []; 

% color map to plot 
map4plot = viridis(100); % for raster
RdBu = cbrewer('div', 'RdBu', 100); % for volcano

% get unique animal list 
animals = unique({experiments.animal_ID}); 

% loop animal by animal (because we lump some experiments from the same animal together) 
% we want a matrix of [cells X time] together, so we need to loop by animal
% if one animal has multiple experiments, they are looped inside the animal loop. Cell alignment is done
for animal_idx = 1 : length(animals)
    animal = animals{animal_idx}; 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, animal)); 

    % loop through all experiments of the animal 
    % this time only to gather all clusters 
    cells = []; 
    for exp_idx = 1 : size(exp4mouse, 2) 
        % select experiments
        experiment = exp4mouse(exp_idx); 
        % load spike matrix 
        load([folder4matrix area '\' experiment.name])
        % union cluster labels
        cells = [cells, clusters]; 

        clearvars spike_matrix clusters
    end % 1st exp loop end 
    cells = unique(cells); % remove duplicates 

    % initalize ramp spikes variable for animals, [cells X time X trials] 
    rampspikes = []; 
    % loop again, but this time to actually load in spike data 
    for exp_idx = 1 : size(exp4mouse, 2)
        % select experiments
        experiment = exp4mouse(exp_idx);
        % load spike matrix but only leave clusters 
        load([folder4matrix area '\' experiment.name])
        clearvars spike_matrix 
        % load opto matrix 
        load([folder4ramps area '\' experiment.name])
        temp = permute(SUAdata_ramp.ramp_spike_matrix, [2 3 1]); 
        % assign values to opto 
        temp2 = zeros(numel(cells), 10000, size(temp, 3));
        [~ ,locb] = ismember(clusters, cells); 
        temp2(locb, :, :) = temp; 
        rampspikes = cat(3, rampspikes, temp2); 
        
        clearvars SUAdata_ramp temp temp2 clusters locb
    end % 2nd exp loop end 


    % average by trials and assign to total spike matrix 
    spikes_tot = [spikes_tot; mean(rampspikes, 3)]; % nanmean to average by trials 

    % another vector to indicate experiment condition 
    if ~isnan(experiment.IUEconstruct)
        condition = [condition; ones([numel(cells), 1])];
    else 
        condition = [condition; zeros([numel(cells), 1])]; 
    end % if loop end for exp conditions 

    % another vector for age 
    age = [age; repmat(experiment.age, [numel(cells), 1])];

    % collect all cells 
    allcells = [allcells; cells']; 

    % all animals 
    mice = [mice; repmat({experiment.animal_ID}, [numel(cells), 1])];

    % calculate OMI and p values 
    % first sum up all spikes during each period [cells X trials] 
    pre = squeeze(sum(rampspikes(:, 1:3000, :), 2));
    during = squeeze(sum(rampspikes(:, 3001:6000, :), 2));
    post = squeeze(sum(rampspikes(:, 6001:9000, :), 2));
    % calculate OMI, average across trial dimension 
    OMI_animal = nanmean((during - pre) ./ (during + pre), 2)';
    OMI_animal_post = nanmean((post - pre) ./ (post + pre), 2)'; 
    % calculate p vlaue 
    % first initialize 
    pvalue_animal = zeros(1, size(pre, 1)); % preallocate
    pvalue_animal_post = zeros(1, size(pre, 1)); % preallocate
    % calculate unit by unit 
    for unit = 1 : size(pre, 1)
        pvalue_animal(unit) = signrank(pre(unit, :), during(unit, :)); % compute pvalue of "modulation index"
        pvalue_animal_post(unit) = signrank(pre(unit, :), post(unit, :)); % compute pvalue of "modulation index"
    end
    % concatenate to global variables
    OMI = [OMI, OMI_animal]; 
    OMIpost = [OMIpost, OMI_animal_post]; 
    pvalue = [pvalue, pvalue_animal]; 
    pvalue_post = [pvalue_post, pvalue_animal_post];
   
end % animal loop end 


% downsample in the time dimension of spike_tot 
% lin alg trick to downsample to save time: chop up, reshape into three dimensions, squeeze the new dimension
spikes_reduced = squeeze(mean(reshape(spikes_tot, size(spikes_tot, 1), 100, []), 2)); 
% zscore
zscored_units = zscore(spikes_reduced, [], 2); 


% sort of raster map like github mouseland
% sort spike trains by similarity but only use "central" part to stress opto differences
% plot units from stim experiments 
units2plot = zscored_units(condition == 1, :);
idx_sorted = sort_spike_trains(units2plot);
figure; % new figure 
imagesc(units2plot(idx_sorted, :), [-1 3]); colormap(map4plot);
hold on;
plot([size(spikes_reduced, 2) / 10 * 3 size(spikes_reduced, 2) / 10 * 3], ...
    get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
plot([size(spikes_reduced, 2) / 10 * 6 size(spikes_reduced, 2) / 10 * 6], ...
    get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
ylabel('Single units');
xticks([3 6 9]* size(spikes_reduced, 2) / 10); 
xticklabels({3 6 9}); 
xlabel('Time (s)')
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial')
title([area ', stim group'], 'FontWeight', 'normal')
% plot units from ctrl experiments 
units2plot = zscored_units(condition == 0, :);
idx_sorted = sort_spike_trains(units2plot);
figure; % new figure 
imagesc(units2plot(idx_sorted, :), [-1 3]); colormap(map4plot);
hold on;
plot([size(spikes_reduced, 2) / 10 * 3 size(spikes_reduced, 2) / 10 * 3], ...
    get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
plot([size(spikes_reduced, 2) / 10 * 6 size(spikes_reduced, 2) / 10 * 6], ...
    get(gca, 'ylim'), 'k', 'linewidth', 1) % reference line for opto
ylabel('Single units');
xticks([3 6 9]* size(spikes_reduced, 2) / 10); 
xticklabels({3 6 9}); 
xlabel('Time (s)')
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial')
title([area ', ctrl group'], 'FontWeight', 'normal')


% PSTH line profile 
figure;
units2plot = zscored_units(condition == 1, :);
boundedline(linspace(0, 10, size(units2plot, 2)), nanmean(units2plot), nanstd(units2plot) ./ sqrt(size(units2plot, 1)))
hold on; 
units2plot = zscored_units(condition == 0, :);
boundedline(linspace(0, 10, size(units2plot, 2)), nanmean(units2plot), nanstd(units2plot) ./ sqrt(size(units2plot, 1)), 'cmap', [0.65 0.65 0.65])
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end
xline(3, ':k', 'linewidth', 1.5) % reference line for opto
xline(6, ':k', 'linewidth', 1.5) % reference line for opto
legend({'', 'stim', '', 'ctrl', '', ''}); legend boxoff
ylabel('Z-scored firing rate (A.U.)'); 
xlabel('Time (s)'); 
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2)
title(area, 'FontWeight', 'normal')


% volcano plots for opto modulation 
% plot for stim group 
num_spikes = sum(spikes_tot(condition == 1, :), 2); % for size only
num_spikes(num_spikes == 0) = 0.1; % scatter can't handle 0 as an input for size
max_spikes = max(num_spikes);
scaling_factor = 300 / max_spikes;
% during stim volcano plot
figure; hold on
scatter(OMI(condition == 1), - log10(pvalue(condition == 1)), num_spikes * scaling_factor, pvalue(condition == 1) < 0.01, 'filled');
colormap(flip(RdBu)); 
alpha(0.5);
clim([-0.1 1.1])
xline(0, 'k', 'linewidth', 1) % reference line for no modulation
xlim([-1.1 1.1]); 
ylim([-0.1 ceil(max(- log10(pvalue)))])
ylabel('- Log10 (p value)'); 
xlabel('Modulation Index'); 
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2)
title(area, 'FontWeight', 'normal')
% post stim volcano plot
figure; hold on
scatter(OMIpost(condition == 1), - log10(pvalue_post(condition == 1)), num_spikes * scaling_factor, pvalue_post(condition == 1) < 0.01, 'filled');
colormap(flip(RdBu)); 
alpha(0.5);
clim([-0.1 1.1])
xline(0, 'k', 'linewidth', 1) % reference line for no modulation
xlim([-1.1 1.1]); 
ylim([-0.1 ceil(max(- log10(pvalue)))])
ylabel('- Log10 (p value)'); 
xlabel('Post Modulation Index'); 
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2)
title(area, 'FontWeight', 'normal')

% plot for control  group 
num_spikes = sum(spikes_tot(condition == 0, :), 2); % for size only
num_spikes(num_spikes == 0) = 0.1; % scatter can't handle 0 as an input for size
max_spikes = max(num_spikes);
scaling_factor = 300 / max_spikes;
% during stim volcano plot
figure; hold on
scatter(OMI(condition == 0), - log10(pvalue(condition == 0)), num_spikes * scaling_factor, pvalue(condition == 0) < 0.01, 'filled');
colormap(flip(RdBu)); 
alpha(0.5);
clim([-0.1 1.1])
xline(0, 'k', 'linewidth', 1) % reference line for no modulation
xlim([-1.1 1.1]); 
ylim([-0.1 ceil(max(- log10(pvalue)))])
ylabel('- Log10 (p value)'); 
xlabel('Modulation Index'); 
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2)
title([area ' ctrl group'], 'FontWeight', 'normal')
% post stim volcano plot
figure; hold on
scatter(OMIpost(condition == 0), - log10(pvalue_post(condition == 0)), num_spikes * scaling_factor, pvalue_post(condition == 0) < 0.01, 'filled');
colormap(flip(RdBu)); 
alpha(0.5);
clim([-0.1 1.1])
xline(0, 'k', 'linewidth', 1); % reference line for no modulation
xlim([-1.1 1.1]); 
ylim([-0.1 ceil(max(- log10(pvalue)))]);
ylabel('- Log10 (p value)'); 
xlabel('Post Modulation Index'); 
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2);
title([area ' ctrl group'], 'FontWeight', 'normal');


end 