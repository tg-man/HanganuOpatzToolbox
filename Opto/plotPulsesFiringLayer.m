function [spikes_tot, animal] = plotPulsesFiringLayer(experiments, BrainArea, StimArea, folder4suainfo, layer, pulse_length, folder4matrix, folder4stim, folder4pulses)
%% Tony Dec 2023. from Mattia's script for Henrik 

map4plot = viridis(100);
Gwindow = gausswin(51, 5); % gaussian window of 100ms with stdev of 20ms 
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
save_data = 1;
repeatCalc = 0;
spikes_tot = [];
firing_tot = []; 
pvalue = [];
idx = 1;


for n_animal = 1 : length(experiments)
    experiment = experiments(n_animal);

    animal{idx} = experiment.animal_ID;
    idx = idx +1;
    PulsesSpikes = getPulsesSpikeMatrix(experiment, save_data, repeatCalc, ...
        pulse_length, folder4matrix, folder4stim, BrainArea, folder4pulses); % just loading it now since this is usually calculated before
    
    % add a pulse2plot variable and do the selection here with conditional
    % statement 

    if isfield(PulsesSpikes, 'pulse_spike_matrix50')
        spikes_animal = PulsesSpikes.pulse_spike_matrix50; 

        % trim opto matrix to leave only sup or deep cells 
        load([folder4suainfo experiment.animal_ID]); 
        for i = 1 : numel(SUAinfo) % find out which SUAinfo cell to use 
            if strcmp(SUAinfo{1, i}(1).file, experiment.name)
                channels = [SUAinfo{1, i}.channel]; 
            end 
        end 
        if strcmp(layer, 'sup')
            spikes_animal = spikes_animal(:, channels < 9, :); 
        elseif strcmp(layer, 'deep')
            spikes_animal = spikes_animal(:, channels > 8, :); 
        end 

        if ~isnan(spikes_animal) 
            if size(spikes_animal, 2) > 1 
                spikes_units = squeeze(mean(spikes_animal)); 
            else 
                spikes_units = squeeze(mean(spikes_animal))'; 
            end 
            
            spikes_tot = cat(1, spikes_tot, spikes_units); 
    %         firing_tot = cat(1, firing_tot, firing_units);
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
xline(0);xline(50); xlim([-300 300])
ylabel('Single units'); xlabel('Time (ms)')
title([BrainArea layer ' to ' StimArea ' stim'])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial')

figure;
boundedline(linspace(-500, 1000, size(spikes_ds, 2)), mean(spikes_ds), std(spikes_ds) ./ sqrt(size(spikes_ds, 1)))
hold on
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end
xline(0, ':k', 'linewidth', 1.5) % reference line for opto
xline(50, ':k', 'linewidth', 1.5); 
ylabel('Aveage FR (Hz)'); xlabel('Time (ms)'); xlim([-250 250])
title(['SUA FR in ' BrainArea layer ' to ' StimArea ' Stim'])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2)
set(gca, 'YScale', 'log'); 

figure;
boundedline(linspace(-500, 1000, size(zscored_units, 2)), mean(zscored_units), std(zscored_units) ./ sqrt(size(zscored_units, 1)))
hold on
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end
xline(0, ':k', 'linewidth', 1.5) % reference line for opto
xline(50, ':k', 'linewidth', 1.5); 
ylabel('z-score FR (AU)'); xlabel('Time (ms)'); xlim([-250 250])
title(['SUA FR in ' BrainArea layer ' to ' StimArea ' Stim'])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2)



end 


