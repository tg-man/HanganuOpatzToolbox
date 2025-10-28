function [spikes_tot, allcells, mice, age] = plotPulseSpikes(experiments, area, folder4matrix, folder4pulses, pulse2plot)
% Tony May 2025
% if stim type needs to be specific, experiments needs to be filtered beforehand 

spikes_tot = [];
condition = []; 
allcells = []; 
mice = []; 
age = []; 
OMI = []; 
pvalue = [];

% gaussian window of 100ms with stdev of 20ms 
Gwindow = gausswin(51, 5); 
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel

% color map to plot 
map4plot = viridis(100); % for raster
RdBu = cbrewer('div', 'RdBu', 100); % for volcano

% get unique animal list 
animals = unique({experiments.animal_ID}); 

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


    % initalize pulse spikes variable for animals, [cells X time X trials] 
    % pulse spike matrix is 1500ms long, with pulse at 500ms 
    pulsespikes = []; 
    % loop again, but this time to actually load in spike data 
    for exp_idx = 1 : size(exp4mouse, 2)
        % select experiments
        experiment = exp4mouse(exp_idx);
        % load spike matrix but only leave clusters 
        load([folder4matrix area '\' experiment.name])
        clearvars spike_matrix 
        % load opto matrix 
        load([folder4pulses area '\' experiment.name])
        % permute dimension to have [cell X time X trials]
        temp = permute(SUAdata_pulses.(['pulse_spike_matrix' num2str(pulse2plot*1000)]), [2 3 1]); 
        % assign values to opto 
        temp2 = zeros(numel(cells), size(temp, 2), size(temp, 3));
        [~ ,locb] = ismember(clusters, cells); 
        temp2(locb, :, :) = temp; 
        pulsespikes = cat(3, pulsespikes, temp2); 

        clearvars SUAdata_ramp temp temp2 clusters locb
    end % 2nd exp loop end 


    % average by trials and assign to total spike matrix 
    spikes_tot = [spikes_tot; mean(pulsespikes, 3)]; % nanmean to average by trials 

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
    pre = squeeze(sum(pulsespikes(:, (499 - pulse2plot*1000) : 498, :), 2));
    during = squeeze(sum(pulsespikes(:, 501 : (500 + pulse2plot*1000), :), 2));
    % calculate OMI, average across trial dimension 
    OMI_animal = nanmean((during - pre) ./ (during + pre), 2)';
    % calculate p vlaue 
    % first initialize 
    pvalue_animal = zeros(1, size(pre, 1)); % preallocate
    % calculate unit by unit 
    for unit = 1 : size(pre, 1)
        pvalue_animal(unit) = signrank(pre(unit, :), during(unit, :)); % compute pvalue of "modulation index"
    end
    % concatenate to global variables
    OMI = [OMI, OMI_animal]; 
    pvalue = [pvalue, pvalue_animal]; 
   
end % animal loop end 


% convolve
spikes_ds = downsamp_convolve(spikes_tot, Gwindow, 1); 
% downsample 
spikes_ds = squeeze(mean(reshape(spikes_ds, size(spikes_tot, 1), 5, []), 2));
% zscore
zscored_units= zscore(spikes_ds, [], 2); 


% plot rasters
% for stim group 
units2plot = zscored_units(condition == 1, 51:150); 
idx_sorted = sort_peak_time(units2plot, 10);
figure; 
imagesc(linspace(-251, 250, size(units2plot, 2)), 1:size(units2plot, 1), flipud(units2plot(idx_sorted, :))); 
colormap(map4plot); 
box off; 
xline(0); 
xline(pulse2plot*1000); % laser reference 
ylabel('Single units'); xlabel('Time (ms)')
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial')
title(area, 'FontWeight', 'normal')
% for control group 
units2plot = zscored_units(condition == 0, 51:150); 
idx_sorted = sort_peak_time(units2plot, 10);
figure; 
imagesc(linspace(-251, 250, size(units2plot, 2)), 1:size(units2plot, 1), flipud(units2plot(idx_sorted, :))); 
colormap(map4plot); 
box off; 
xline(0); 
xline(pulse2plot*1000); % laser reference 
ylabel('Single units'); xlabel('Time (ms)')
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial')
title([area ' ctrl group'], 'FontWeight', 'normal')


% PSTH line plot 
figure;
units2plot = zscored_units(condition == 1, :);
boundedline(linspace(-500, 1000, size(zscored_units, 2)), nanmean(units2plot), nanstd(units2plot) ./ sqrt(size(units2plot, 1)))
hold on; 
units2plot = zscored_units(condition == 0, :);
boundedline(linspace(-500, 1000, size(zscored_units, 2)), nanmean(units2plot), nanstd(units2plot) ./ sqrt(size(units2plot, 1)), 'cmap', [0.65 0.65 0.65])
ylabel('Firing rate z-score (A.U.)'); 
xlabel('Time (ms)'); 
xlim([-249 250]);
set(gca, 'TickDir', 'out', 'FontSize', 18, 'FontName', 'Arial', 'LineWidth', 2); 
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end
fill([0 0 pulse2plot*1000 pulse2plot*1000], [-0.5 2 2 -0.5], [0 0.30 1], 'FaceAlpha', 0.3, 'EdgeColor', 'none')
title(area, 'FontWeight', 'normal')


% volcano plots for opto modulation 
% plot for stim group during stim volcano plot
num_spikes = sum(spikes_tot(condition == 1, :), 2); % for size only
num_spikes(num_spikes == 0) = 0.1; % scatter can't handle 0 as an input for size
max_spikes = max(num_spikes);
scaling_factor = 300 / max_spikes;
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
% plot for control  group  during stim volcano plot
num_spikes = sum(spikes_tot(condition == 0, :), 2); % for size only
num_spikes(num_spikes == 0) = 0.1; % scatter can't handle 0 as an input for size
max_spikes = max(num_spikes);
scaling_factor = 300 / max_spikes;
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


end 
