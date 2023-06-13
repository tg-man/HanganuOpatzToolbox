%% Plotting script to Basic LFP Analysis
% two sections: 1) plotting LFP properties 
%               2) plotting PSD 
%% LFP properties 
clear

% load experiments and generic stuff
experiments = get_experiment_redux; 
experiments = experiments([1:73]); % what experiments to keep

% folders to grab various results
folder4osc = 'Q:\Personal\Tony\Analysis\Results_3Probe_osc\';

% initialize variables
time_in_osc = NaN(size(experiments, 2), 2);
num_osc = time_in_osc;
duration = time_in_osc;
amplitude = time_in_osc;

% compute all sort of computations, on an experiment by experiment basis
for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
     % load oscillations
    load(strcat(folder4osc, experiment.animal_ID, '_PFC'));
    timestamps = extractfield(oscillations, 'timestamps');
    time_in_osc(exp_idx,1) = sum(oscillations.durations) ./ (oscillations.len_rec - oscillations.len_artifact);
    num_osc(exp_idx,1) = size(oscillations.durations, 1) / ((oscillations.len_rec - oscillations.len_artifact) / (60*200));
    duration(exp_idx,1) = nanmedian(oscillations.durations / 200); % in seconds
    amplitude(exp_idx,1) = nanmedian(oscillations.peakAbsPower); 
    clear oscillations 
    load(strcat(folder4osc, experiment.animal_ID, '_Str'));
    timestamps = extractfield(oscillations, 'timestamps');
    time_in_osc(exp_idx,2) = sum(oscillations.durations) ./ (oscillations.len_rec - oscillations.len_artifact);
    num_osc(exp_idx,2) = size(oscillations.durations, 1) / ((oscillations.len_rec - oscillations.len_artifact) / (60*200));
    duration(exp_idx,2) = nanmedian(oscillations.durations / 200); %in seconds
    amplitude(exp_idx,2) = nanmedian(oscillations.peakAbsPower); 
    clear oscillations 
    load(strcat(folder4osc, experiment.animal_ID, '_TH'));
    timestamps = extractfield(oscillations, 'timestamps');
    time_in_osc(exp_idx,3) = sum(oscillations.durations) ./ (oscillations.len_rec - oscillations.len_artifact);
    num_osc(exp_idx,3) = size(oscillations.durations, 1) / ((oscillations.len_rec - oscillations.len_artifact) / (60*200));
    duration(exp_idx,3) = nanmedian(oscillations.durations / 200); %in seconds
    amplitude(exp_idx,3) = nanmedian(oscillations.peakAbsPower); 
end

YlGnBu = cbrewer('seq', 'YlGnBu', 100); % call colormap 

% Time in active periods 
figure; set(gcf,'position',[100,100,900,450])
subplot(131);violins = violinplot(time_in_osc(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.45);hold on; 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Time in Active Periods'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('PFC', 'FontSize', 14);

subplot(132); violins = violinplot(time_in_osc(:,2), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Time in Active Periods'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Str', 'FontSize', 14);

subplot(133); violins = violinplot(time_in_osc(:,3), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Time in Active Periods'); ylim([0 1]); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('TH', 'FontSize', 14);
sgtitle('Time in active periods','FontSize', 18, 'FontWeight', 'Bold'); 

% Number of active Periods
figure; set(gcf, 'position', [100,100,900,450])
subplot(131);violins = violinplot(num_osc(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.45);hold on; 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('# active periods/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('PFC', 'FontSize', 14);

subplot(132); violins = violinplot(num_osc(:,2), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('# active periods/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Str', 'FontSize', 14);

subplot(133); violins = violinplot(num_osc(:,3), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('# active periods/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('TH', 'FontSize', 14);
sgtitle('Number of active periods','FontSize', 18, 'FontWeight', 'Bold'); 

% Duration of active Periods
figure; set(gcf, 'position', [100,100,900,450])
subplot(131);violins = violinplot(duration(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.45);hold on; 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('PFC', 'FontSize', 14);

subplot(132); violins = violinplot(duration(:,2), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Str', 'FontSize', 14);

subplot(133); violins = violinplot(duration(:,3), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('TH', 'FontSize', 14);
sgtitle('Median duration of active periods','FontSize', 18, 'FontWeight', 'Bold'); 

% Amplitude of active Periods
figure; set(gcf, 'position', [100,100,900,450])
subplot(131);violins = violinplot(amplitude(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.45);hold on; 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
set(gca, 'YScale', 'log'); ylim([100 1500])
title('PFC', 'FontSize', 14);

subplot(132); violins = violinplot(amplitude(:,2), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
set(gca, 'YScale', 'log'); ylim([100 1500])
title('Str', 'FontSize', 14);

subplot(133); violins = violinplot(amplitude(:,3), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
set(gca, 'YScale', 'log'); ylim([100 350])
title('TH', 'FontSize', 14);
sgtitle('Median amplitude of active periods','FontSize', 18, 'FontWeight', 'Bold'); 


%% Plot PSD stuff 
clear

% load experiments and generic stuff
experiments = get_experiment_redux; 
experiments = experiments([45:55 57:63]); % what experiments to keep
folder4PSD = 'Q:\Personal\Tony\Analysis\Results_3Probe_PSD_coactive\';
YlGnBu = cbrewer('seq', 'YlGnBu', 100); % call colormap 

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
    % load PSD 
    load(strcat(folder4PSD, experiment.animal_ID, '_PFC'));
    Power_PFC(exp_idx, :) = nanmedian(PSDstruct.PSD);
    PowerSlow_PFC(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_slow), 3);
    PowerFast_PFC(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_fast), 3);
    clear PSDstruct 
    load(strcat(folder4PSD, experiment.animal_ID, '_Str'));
    Power_Str(exp_idx, :) = nanmedian(PSDstruct.PSD);
    PowerSlow_Str(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_slow), 3);
    PowerFast_Str(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_fast), 3);
    clear PSDstruct 
    load(strcat(folder4PSD, experiment.animal_ID, '_TH'));
    Power_TH(exp_idx, :) = nanmedian(PSDstruct.PSD);
    PowerSlow_TH(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_slow), 3);
    PowerFast_TH(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_fast), 3);
end 

% calculate the boundedline values
n=1; 
for idx = 5:12 
    if ismember (idx, age)
        PowerPlotPFC(n,:) = nanmedian(Power_PFC(age==idx,:), 1); 
        shading1(n,:) = nanstd(Power_PFC(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
        PowerPlotStr(n,:) = nanmedian(Power_Str(age==idx,:), 1); 
        shading2(n,:) = nanstd(Power_Str(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
        PowerPlotTH(n,:) = nanmedian(Power_TH(age==idx,:), 1); 
        shading3(n,:) = nanstd(Power_TH(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
        n = n+1;
    end 
end 

% plotting baseline PSD
figure; 
subplot(311);hold on; 
set(gcf, 'position', [10,10,450,1000])
for idx = 1:size(PowerPlotPFC)
    plot(PSDstruct.freqs, PowerPlotPFC(idx,:), 'Color',  YlGnBu(round(100/8*idx),:)); 
%     boundedline(PSDstruct.freqs, PowerPlotPFC(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));   
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([1 50]); ylim([0.01 20]);
title('PFC', 'FontSize', 14, 'FontName', 'Arial');
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

subplot(312); hold on; 
title('Str', 'FontSize', 14, 'FontName', 'Arial');
for idx = 1:size(PowerPlotStr)
    plot(PSDstruct.freqs, PowerPlotStr(idx,:), 'Color',  YlGnBu(round(100/8*idx),:)); 
%     boundedline(PSDstruct.freqs, PowerPlotStr(idx,:), shading2(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));    
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([1 50]); ylim([0.01 20]);
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

subplot(313); hold on; 
title('TH', 'FontSize', 14, 'FontName', 'Arial');
for idx = 1:size(PowerPlotTH)
    plot(PSDstruct.freqs, PowerPlotTH(idx,:), 'Color',  YlGnBu(round(100/8*idx),:)); 
%     boundedline(PSDstruct.freqs, PowerPlotTH(idx,:), shading3(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));    
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([1 50]); ylim([0.01 20]);
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)
sgtitle('Baseline Power Spectrum', 'FontSize', 16, 'FontName', 'Arial' , 'FontWeight', 'Bold');

% calculate the boundedline values (Fast PSD) 
n=1; 
for idx = 5:12 
    if ismember (idx, age)
    PowerFastPlotPFC(n,:) = nanmedian(PowerFast_PFC(age==idx,:), 1); 
    shading1fast(n,:) = nanstd(PowerFast_PFC(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    PowerFastPlotStr(n,:) = nanmedian(PowerFast_Str(age==idx,:), 1); 
    shading2fast(n,:) = nanstd(PowerFast_Str(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    PowerFastPlotTH(n,:) = nanmedian(PowerFast_TH(age==idx,:), 1); 
    shading3fast(n,:) = nanstd(PowerFast_TH(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    n = n+1;
    end 
end 
% plotting Fast PSD 
figure; hold on; 
title('Fast Power Spectrum (PFC)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(PowerFastPlotPFC)
    boundedline(PSDstruct.freqs_fast, PowerFastPlotPFC(idx,:), shading1fast(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)');
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

figure; hold on; 
title('Fast Power Spectrum (Str)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(PowerFastPlotStr)
    boundedline(PSDstruct.freqs_fast, PowerFastPlotStr(idx,:), shading2fast(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); 
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

figure; hold on; 
title('Fast Power Spectrum (TH)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(PowerFastPlotTH)
    boundedline(PSDstruct.freqs_fast, PowerFastPlotTH(idx,:), shading3fast(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); 
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

% calculate the boundedline values (Slow PSD)
n=1; 
for idx = 5:12 
    if ismember (idx, age)
    PowerSlowPlotPFC(n,:) = nanmedian(PowerSlow_PFC(age==idx,:), 1); 
    shading1slow(n,:) = nanstd(PowerSlow_PFC(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    PowerSlowPlotStr(n,:) = nanmedian(PowerSlow_Str(age==idx,:), 1); 
    shading2slow(n,:) = nanstd(PowerSlow_Str(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    PowerSlowPlotTH(n,:) = nanmedian(PowerSlow_TH(age==idx,:), 1); 
    shading3slow(n,:) = nanstd(PowerSlow_TH(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    n = n+1;
    end 
end 
% plotting Slow PSD 
figure; hold on; 
title('Slow Power Spectrum (PFC)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(PowerSlowPlotPFC)
    boundedline(PSDstruct.freqs_slow, PowerSlowPlotPFC(idx,:), shading1slow(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([0.5 5]); ylim([0 20])
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

figure; hold on; 
title('Slow Power Spectrum (Str)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(PowerSlowPlotStr)
    boundedline(PSDstruct.freqs_slow, PowerSlowPlotStr(idx,:), shading2slow(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([0.5 5]); ylim([0 20])
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

figure; hold on; 
title('Slow Power Spectrum (TH)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(PowerSlowPlotTH)
    boundedline(PSDstruct.freqs_slow, PowerSlowPlotTH(idx,:), shading3slow(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([0.5 5]); ylim([0 20])
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

