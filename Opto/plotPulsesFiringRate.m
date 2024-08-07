function [spikes_tot, animal] = plotPulsesFiringRate(experiments, RespArea, StimArea, pulse_length, pulse2plot, folder4matrix, folder4stim, folder4pulses)
% By Mattia

map4plot = viridis(100);
Gwindow = gausswin(51, 5); % gaussian window of 100ms with stdev of 20ms 
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
save_data = 1;
repeatCalc = 0;
spikes_tot = [];
pvalue = [];
OMI = []; 
idx = 1;

pre_stim = (499 - pulse2plot*1000) : 498; % in ms
stim = 501 : (500 + pulse2plot*1000); % in ms

for n_animal = 1 : length(experiments)
    experiment = experiments(n_animal);
    animal{idx} = experiment.animal_ID;
    idx = idx +1;
    PulsesSpikes = getPulsesSpikeMatrix(experiment, save_data, repeatCalc, ...
        pulse_length, folder4matrix, folder4stim, RespArea, folder4pulses); % just loading it now since this is usually calculated before

    % extract the specified field and get spikes  
    if isfield(PulsesSpikes, ['pulse_spike_matrix' num2str(pulse2plot*1000)])
        spikes_animal = PulsesSpikes.(['pulse_spike_matrix' num2str(pulse2plot*1000)]);
        if ~isnan(spikes_animal) 
            if size(spikes_animal, 2) > 1 
                spikes_units = squeeze(mean(spikes_animal)); 
            else 
                spikes_units = squeeze(mean(spikes_animal))'; 
            end 
            spikes_tot = cat(1, spikes_tot, spikes_units); 
            
            pre = squeeze(sum(spikes_animal(:, :, pre_stim), 3));  % sum all spikes during the pre period 
            during = squeeze(sum(spikes_animal(:, :, stim), 3));   % sum all spikes during stim period 
            OMI_animal = nanmean((during - pre) ./ (during + pre)); % compute modulation index
            pvalue_animal = NaN(1, size(pre, 2)); % preallocate
            for unit = 1 : size(pre, 2)
                pvalue_animal(unit) = signrank(pre(:, unit), during(:, unit)); % compute pvalue of "modulation index"
            end
            OMI = horzcat(OMI, OMI_animal); % concatenate
            pvalue = horzcat(pvalue, pvalue_animal); % concatenate
        end
    end 
end

% spikes_ds = spikes_tot; 
spikes_ds = downsamp_convolve(spikes_tot, Gwindow, 1); 
spikes_ds = squeeze(mean(reshape(spikes_ds, size(spikes_tot, 1), 5, []), 2)); 

zscored_units= zscore(spikes_ds, [], 2); % zscore
idx_sorted = sort_peak_time(zscored_units, 10);
figure; imagesc(linspace(-500, 1000, size(zscored_units, 2)), ...
    1 : size(zscored_units, 1), ...    
    flipud(zscored_units(idx_sorted, :))); colormap(map4plot) % plot
xline(0); xline(pulse2plot*1000); % laser reference 
xlim([-300 300])
ylabel('Single units'); xlabel('Time (ms)')
title([RespArea ' to ' StimArea ' stim '])
set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')

% volcano plot section here 
RdBu = cbrewer('div', 'RdBu', 100);
num_spikes = sum(spikes_tot, 2); % for size only
num_spikes(num_spikes == 0) = 0.1; % scatter can't handle 0 as an input for size
max_spikes = max(num_spikes);
scaling_factor = 200 / max_spikes;
figure; hold on
scatter(OMI, -log10(pvalue), num_spikes * scaling_factor, pvalue < 0.01, 'filled');
colormap(flip(RdBu)); caxis([-0.1 1.1])
xline(0, 'k', 'linewidth', 1) % reference line for no modulation
xlim([-1.1 1.1]); ylim([-0.1 ceil(max(- log10(pvalue)))])
ylabel('- Log10 (pvalue)'); xlabel('Modulation Index'); alpha(0.5)
title([RespArea ' to ' StimArea ' stim '])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2)

% vector plot 
figure;
boundedline(linspace(-500, 1000, size(spikes_ds, 2)), mean(spikes_ds), std(spikes_ds) ./ sqrt(size(spikes_ds, 1)))
hold on
xline(0, ':k', 'LineWidth', 1.5) % reference line for opto
xline(pulse2plot*1000, ':k', 'LineWidth', 1.5); 
ylabel('Aveage FR (Hz)'); xlabel('Time (ms)'); xlim([-250 250])
title(['SUA FR in ' RespArea ' to ' StimArea ' Stim'])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2); 
set(gca, 'YScale', 'log'); 
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end

% vector plot 
figure; hold on
boundedline(linspace(-500, 1000, size(zscored_units, 2)), mean(zscored_units), std(zscored_units) ./ sqrt(size(zscored_units, 1)))
xline(0, ':k', 'LineWidth', 1.5) % reference line for opto
xline(pulse2plot*1000, ':k', 'LineWidth', 1.5); 
ylabel('Z-scored Firing (AU)'); xlabel('Time (ms)'); xlim([-250 250])
title(['SUA FR in ' RespArea ' to ' StimArea ' Stim'])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2); 
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end

end 