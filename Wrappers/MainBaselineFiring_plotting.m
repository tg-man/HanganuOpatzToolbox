%% Generate baseline firing rate plot 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

BrainArea = 'TH'; 
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 

% call colormap 
YlGnBu = cbrewer('seq', 'YlGnBu', 100);

for exp_idx = 1: size(experiments, 2)
    experiment = experiments(exp_idx); 
      
    area_idx = find([strcmp(BrainArea, experiment.Area1) strcmp(BrainArea, experiment.Area2) strcmp(BrainArea, experiment.Area3)]); 
    
    if ~isempty(area_idx) && experiment.(['target' num2str(area_idx)]) == 1 
        load([folder4SM BrainArea filesep experiment.name]);
        len = size(spike_matrix, 2) / 1000; 
        spikes_tot = full(sum(sum(spike_matrix)));   
        fr(exp_idx) = spikes_tot / len; 
    else 
        fr(exp_idx) = NaN; 
    end 
end

age = [experiments.age]; 

figure; violins = violinplot(fr, age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('Spike Rate (Hz)'); xlim([0 9]); ylim([0.01 100])
set(gca, 'FontSize', 16, 'FontName', 'Arial', 'YScale', 'log'); 
title(BrainArea, 'FontSize', 14, 'FontWeight','bold', 'FontName', 'Arial'); 