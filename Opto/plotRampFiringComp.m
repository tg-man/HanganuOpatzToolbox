function  [spikes_tot, animal] = plotRampFiringComp(experiments, Area1, Area2, StimArea, folder4ramps) 
% Tony 
% experiemnts: list from excel 
% area1: string, used to navigate folders
% StimArea: same as above 
% folder4ramps: path where the opto matrices live 

plotwidth = 2; 

spikes_tot1 = [];
spikes_tot2 = [];

for exp_idx = 1: size(experiments, 2) 
    experiment = experiments(exp_idx); 

    if experiment.target2 == 1 
        load([folder4ramps Area1 '\' experiment.name])
        spikes_animal1 = SUAdata_ramp.ramp_spike_matrix; 
        % average across trial and concatenate to total mat for area1 
        if numel(spikes_animal1) > 0
            if size(spikes_animal1, 2) > 1
                spikes_1 = squeeze(mean(spikes_animal1));
            else
                spikes_1 = squeeze(mean(spikes_animal1))';
            end
            spikes_tot1 = cat(1, spikes_tot1, spikes_1);
        end
    end 

    if experiment.target3 == 1
        load([folder4ramps Area2 '\' experiment.name])
        spikes_animal2 = SUAdata_ramp.ramp_spike_matrix; 
        % average across trial and concatenate to total mat for area2
        if numel(spikes_animal2) > 0
            if size(spikes_animal2, 2) > 1
                spikes_2 = squeeze(mean(spikes_animal2));
            else
                spikes_2 = squeeze(mean(spikes_animal2))';
            end
            spikes_tot2 = cat(1, spikes_tot2, spikes_2);
        end
    end 
end 

% downsample spikes from by x100 
spikes_reduced1 = squeeze(mean(reshape(spikes_tot1, size(spikes_tot1, 1), 100, []), 2));
spikes_reduced2 = squeeze(mean(reshape(spikes_tot2, size(spikes_tot2, 1), 100, []), 2));
zscored_units1 = zscore(spikes_reduced1, [], 2); % zscore
zscored_units2 = zscore(spikes_reduced2, [], 2); % zscore

figure; hold on
boundedline(linspace(-3, 7, size(zscored_units1, 2)), mean(zscored_units1), std(zscored_units1) ./ sqrt(size(zscored_units1, 1)))
boundedline(linspace(-3, 7, size(zscored_units2, 2)), mean(zscored_units2), std(zscored_units2) ./ sqrt(size(zscored_units2, 1)), 'cmap', [0.8500 0.3250 0.0980])
% adjust line width 
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = plotwidth;
end
xline(0, 'k:', 'linewidth', 1.5) % reference line for opto
xline(3, 'k:', 'linewidth', 1.5) % reference line for opto
ylabel('z-scored firing rate (A.U.)'); xlabel('Time (s)');
title([Area1 ' vs. ' Area2 ' to ' StimArea ' ramp stim'])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2);
xlim([-3 7]); xticks([-3 0 3 6 ]);
legend('', Area1,'', Area2,'','')

end 