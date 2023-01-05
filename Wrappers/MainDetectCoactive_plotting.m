%% Plotting coactive period stuff

clear
experiments = get_experiment_redux;
experiments = experiments([45:63]); % what experiments to keep
folder4coactive = 'Q:\Personal\Tony\Analysis\Results_3Probe_Coactive\All3_NoArtifact\';
save_data = 1; 
YlGnBu = cbrewer('seq', 'YlGnBu', 100); % call colormap 

for exp_idx = 1:length(experiments) 
    
    % select experiment 
    experiment = experiments(exp_idx);
    
    % set age 
    age(exp_idx) = experiment.age; 
    
    % load coactive period struct
    load(strcat(folder4coactive, experiment.animal_ID));
    
    % calculate some variables
    time(exp_idx) = sum(diff(CoactivePeriods.timestamps,1,2))/CoactivePeriods.len_rec; 
    number(exp_idx) = length(CoactivePeriods.timestamps)/(CoactivePeriods.len_rec/(CoactivePeriods.fs*60)); 
    duration(exp_idx) = nanmedian(diff(CoactivePeriods.timestamps,1,2))/CoactivePeriods.fs; 
end 

% Time in coactive periods 
figure;
violins = violinplot(time, age, 'ViolinAlpha', 0.7, 'Width', 0.45);hold on; 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Time in Coactive Periods'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); 

% duration of active periods 
figure;
violins = violinplot(duration, age, 'ViolinAlpha', 0.7, 'Width', 0.45);hold on; 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Median duration of coactive periods (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); 

% number of active periods 
figure;
violins = violinplot(number, age, 'ViolinAlpha', 0.7, 'Width', 0.45);hold on; 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Count/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); 
