%% Plotting script to Basic LFP Analysis
% two sections: 1) plotting LFP properties 
%               2) plotting PSD 
%% LFP properties 
clear

% load experiments and generic stuff
experiments = get_experiment_redux; 
experiments = experiments(); % what experiments to keep
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

% folders to grab results
folder4osc = 'Q:\Personal\Tony\Analysis\Results_osc\';

% call colormap 
YlGnBu = cbrewer('seq', 'YlGnBu', 100);

% initialize variables
time_in_osc = NaN(size(experiments, 2), 3);
num_osc = time_in_osc;
duration = time_in_osc;
amplitude = time_in_osc;

% compute all sort of computations, on an experiment by experiment basis
for exp_idx = 1 : size(experiments, 2)
    disp(['loading data exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])

    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
    % load oscillations and populate variables one by one 
    % area 1 
    if experiment.target1 == 1 
        load([folder4osc experiment.Area1 '\' experiment.animal_ID]); 
        time_in_osc(exp_idx,1) = sum(oscillations.durations) ./ (oscillations.len_rec - oscillations.len_artifact);
        num_osc(exp_idx,1) = size(oscillations.durations, 1) / ((oscillations.len_rec - oscillations.len_artifact) / (60*200)); % per minute, hence the huge denominator 
        duration(exp_idx,1) = nanmedian(oscillations.durations / 200); % in seconds
        amplitude(exp_idx,1) = nanmedian(oscillations.peakAbsPower); 
    else
        time_in_osc(exp_idx,1) = NaN;
        num_osc(exp_idx,1) = NaN; 
        duration(exp_idx,1) = NaN; % in seconds
        amplitude(exp_idx,1) = NaN; 
    end 
    clear oscillations 

    % area 2
    if experiment.target2 == 1 
        load([folder4osc experiment.Area2 '\' experiment.animal_ID]); 
        time_in_osc(exp_idx,2) = sum(oscillations.durations) ./ (oscillations.len_rec - oscillations.len_artifact);
        num_osc(exp_idx,2) = size(oscillations.durations, 1) / ((oscillations.len_rec - oscillations.len_artifact) / (60*200)); % per minute, hence the huge denominator 
        duration(exp_idx,2) = nanmedian(oscillations.durations / 200); %in seconds
        amplitude(exp_idx,2) = nanmedian(oscillations.peakAbsPower); 
    else
        time_in_osc(exp_idx,2) = NaN;
        num_osc(exp_idx,2) = NaN; 
        duration(exp_idx,2) = NaN; % in seconds
        amplitude(exp_idx,2) = NaN;
    end 
    clear oscillations 

    % area 3 
    if strcmp(experiment.sites, '3site') && experiment.target3 == 1
        load([folder4osc experiment.Area3 '\' experiment.animal_ID]); 
        time_in_osc(exp_idx,3) = sum(oscillations.durations) ./ (oscillations.len_rec - oscillations.len_artifact);
        num_osc(exp_idx,3) = size(oscillations.durations, 1) / ((oscillations.len_rec - oscillations.len_artifact) / (60*200));
        duration(exp_idx,3) = nanmedian(oscillations.durations / 200); %in seconds
        amplitude(exp_idx,3) = nanmedian(oscillations.peakAbsPower); 
    else
        time_in_osc(exp_idx,3) = NaN;
        num_osc(exp_idx,3) = NaN; 
        duration(exp_idx,3) = NaN; % in seconds
        amplitude(exp_idx,3) = NaN;
    end 
    clear oscillations 
end

% Time in active periods 
figure; violins = violinplot(time_in_osc(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('Time in Active Periods'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); xlim([0 9]); ylim([0 1.05]);
title('ACC', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(time_in_osc(:,2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('Time in Active Periods'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); xlim([0 9]); ylim([0 1.05]);
title('Str', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(time_in_osc(:,3), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('Time in Active Periods'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); xlim([0 9]); ylim([0 1.05]);
title('TH', 'FontSize', 16, 'FontName', 'Arial');

% Number of active Periods
figure; violins = violinplot(num_osc(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('Active periods/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); xlim([0 9]); ylim([0 16]);
title('ACC', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(num_osc(:,2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('Active periods/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); xlim([0 9]); ylim([0 16]);
title('Str', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(num_osc(:,3), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('Active periods/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); xlim([0 9]); ylim([0 16]);
title('TH', 'FontSize', 16, 'FontName', 'Arial');

% Duration of active Periods
figure; violins = violinplot(duration(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); 
set(gca, 'YScale', 'log'); xlim([0 9]); ylim([0 150]);
title('ACC', 'FontSize', 16, 'FontName', 'Arial'); 

figure; violins = violinplot(duration(:,2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); 
set(gca, 'YScale', 'log'); xlim([0 9]); ylim([0 150]);
title('Str', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(duration(:,3), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial'); 
set(gca, 'YScale', 'log'); xlim([0 9]); ylim([0 150]);
title('TH', 'FontSize', 16, 'FontName', 'Arial');

% Amplitude of active Periods
figure; violins = violinplot(amplitude(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
set(gca, 'YScale', 'log'); xlim([0 9]); ylim([70 2200]);
title('ACC', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(amplitude(:,2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
set(gca, 'YScale', 'log'); xlim([0 9]); ylim([70 2200]);
title('Str', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(amplitude(:,3), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
set(gca, 'YScale', 'log'); xlim([0 9]); ylim([70 2200]);
title('TH', 'FontSize', 16, 'FontName', 'Arial');


%% Plot PSD stuff 
clear

% load experiments and generic stuff
experiments = get_experiment_redux; 
% experiments = experiments(); % what experiments to keep
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

% folders to grab various results
folder4PSD = 'Q:\Personal\Tony\Analysis\Results_PSD\';

% call colormap 
YlGnBu = cbrewer('seq', 'YlGnBu', 100);

% initialize variables 
Power_ACC = NaN(size(experiments,2), 108); 
Power_Str = Power_ACC; 
Power_TH = Power_ACC; 
PowerSlow_ACC = NaN(size(experiments,2), 98); 
PowerSlow_Str = PowerSlow_ACC; 
PowerSlow_TH = PowerSlow_ACC; 
PowerFast_ACC = NaN(size(experiments,2), 244); 
PowerFast_Str = PowerFast_ACC; 
PowerFast_TH = PowerFast_ACC; 

% compute all sort of computations, on an experiment by experiment basis
for exp_idx = 1 : size(experiments, 2)
    disp(['loading data exp # ' num2str(exp_idx) '/' num2str(size(experiments, 2))])

    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
    % load PSD and populate variables one by one 
    % load ACC
    if experiment.target1 == 1 
        load([folder4PSD experiment.Area1 '\' experiment.animal_ID]); 
        Power_ACC(exp_idx, :) = nanmedian(PSDstruct.PSD);
        PowerSlow_ACC(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_slow), 3);
        PowerFast_ACC(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_fast), 3);
        freqs = PSDstruct.freqs; 
        freqs_fast = PSDstruct.freqs_fast; 
        freqs_slow = PSDstruct.freqs_slow; 
    else 
        Power_ACC(exp_idx, :) = NaN;
        PowerSlow_ACC(exp_idx, :) = NaN;
        PowerFast_ACC(exp_idx, :) = NaN;
    end
    clear PSDstruct 

    % load Str
    if experiment.target2 == 1 
        load([folder4PSD experiment.Area2 '\' experiment.animal_ID]); 
        Power_Str(exp_idx, :) = nanmedian(PSDstruct.PSD);
        PowerSlow_Str(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_slow), 3);
        PowerFast_Str(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_fast), 3);
    else 
        Power_Str(exp_idx, :) = NaN;
        PowerSlow_Str(exp_idx, :) = NaN;
        PowerFast_Str(exp_idx, :) = NaN;
    end
    clear PSDstruct
   
    % load TH
    if strcmp(experiment.sites, '3site') && experiment.target3 == 1
        load([folder4PSD experiment.Area3 '\' experiment.animal_ID]); 
        Power_TH(exp_idx, :) = nanmedian(PSDstruct.PSD);
        PowerSlow_TH(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_slow), 3);
        PowerFast_TH(exp_idx, :) = nanmedian(nanmedian(PSDstruct.PSD_fast), 3);
    else 
        Power_TH(exp_idx, :) = NaN;
        PowerSlow_TH(exp_idx, :) = NaN;
        PowerFast_TH(exp_idx, :) = NaN;
    end
    clear PSDstruct
end 

% calculate the boundedline values
n=1; 
for idx = 5:12 
    if ismember (idx, age)
        PowerPlotACC(n,:) = nanmedian(Power_ACC(age==idx,:), 1); 
%         shading1(n,:) = nanstd(Power_PFC(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
        PowerPlotStr(n,:) = nanmedian(Power_Str(age==idx,:), 1); 
%         shading2(n,:) = nanstd(Power_Str(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
        PowerPlotTH(n,:) = nanmedian(Power_TH(age==idx,:), 1); 
%         shading3(n,:) = nanstd(Power_TH(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    else
        PowerPlotPFC(n,:) = NaN; 
%         shading1(n,:) = NaN; 
        PowerPlotStr(n,:) = NaN; 
%         shading2(n,:) = NaN; 
        PowerPlotTH(n,:) = NaN; 
%         shading3(n,:) = NaN;   
    end
    n = n+1; 
end

% plotting baseline PSD
figure; hold on; 
for idx = 1:size(PowerPlotACC)
    plot(freqs, PowerPlotACC(idx,:), 'LineWidth', 2, 'Color', YlGnBu(round(100/8*idx),:)); 
%     boundedline(PSDstruct.freqs, PowerPlotPFC(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));   
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([1 50]); ylim([0.01 30]);
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16);
title('ACC', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_ACC, 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Broadband Power (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); ylim([5 1500]);
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('ACC', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_ACC(:, freqs < 4) , 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Power < 4 Hz (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); 
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('ACC', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_ACC(:, freqs > 4 & freqs < 12) , 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Power 4 - 12 Hz (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); 
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('ACC', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_ACC(:, freqs > 12) , 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Power > 12 Hz (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); 
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('ACC', 'FontSize', 16, 'FontName', 'Arial');

figure; hold on; 
for idx = 1:size(PowerPlotStr)
    plot(freqs, PowerPlotStr(idx,:), 'LineWidth', 2, 'Color', YlGnBu(round(100/8*idx),:)); 
%     boundedline(PSDstruct.freqs, PowerPlotPFC(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));   
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([1 50]); ylim([0.01 30]);
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16);
title('Str', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_Str, 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Broadband Power (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); ylim([5 1500]);
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('Str', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_Str(:, freqs < 4) , 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Power < 4 Hz (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); 
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('Str', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_Str(:, freqs > 4 & freqs < 12) , 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Power 4 - 12 Hz (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); 
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('Str', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_Str(:, freqs > 12) , 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Power > 12 Hz (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); 
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('Str', 'FontSize', 16, 'FontName', 'Arial');

figure; hold on; 
for idx = 1:size(PowerPlotTH)
    plot(freqs, PowerPlotTH(idx,:), 'LineWidth', 2, 'Color', YlGnBu(round(100/8*idx),:)); 
%     boundedline(PSDstruct.freqs, PowerPlotPFC(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));   
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([1 50]); ylim([0.01 30]);
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16);
title('TH', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_TH, 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Broadband Power (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); ylim([5 1500]);
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('TH', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_TH(:, freqs < 4) , 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Power < 4 Hz (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); 
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('TH', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_TH(:, freqs > 4 & freqs < 12) , 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Power 4 - 12 Hz (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); 
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('TH', 'FontSize', 16, 'FontName', 'Arial');

figure; violins = violinplot(sum(Power_TH(:, freqs > 12) , 2), age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Power > 12 Hz (\muV^2)'); xlabel('Age (p)'); xlim([0.5 8.5]); 
set(gca, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 2.5);
title('TH', 'FontSize', 16, 'FontName', 'Arial');


% % calculate the boundedline values (Fast PSD) 
% % calculate the boundedline values
% n=1; 
% for idx = 5:12 
%     if ismember (idx, age)
%         PowerPlotACC(n,:) = nanmedian(Power_ACC(age==idx,:), 1); 
% %         shading1(n,:) = nanstd(Power_PFC(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
%         PowerPlotStr(n,:) = nanmedian(Power_Str(age==idx,:), 1); 
% %         shading2(n,:) = nanstd(Power_Str(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
%         PowerPlotTH(n,:) = nanmedian(Power_TH(age==idx,:), 1); 
% %         shading3(n,:) = nanstd(Power_TH(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
%     else
%         PowerPlotPFC(n,:) = NaN; 
% %         shading1(n,:) = NaN; 
%         PowerPlotStr(n,:) = NaN; 
% %         shading2(n,:) = NaN; 
%         PowerPlotTH(n,:) = NaN; 
% %         shading3(n,:) = NaN;   
%     end
%     n = n+1; 
% end
% % plotting Fast PSD 
% figure; hold on; 
% title('Fast Power Spectrum (PFC)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
% for idx = 1:size(PowerFastPlotPFC)
%     boundedline(PSDstruct.freqs_fast, PowerFastPlotPFC(idx,:), shading1fast(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
% end 
% ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)');
% set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)
% 
% figure; hold on; 
% title('Fast Power Spectrum (Str)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
% for idx = 1:size(PowerFastPlotStr)
%     boundedline(PSDstruct.freqs_fast, PowerFastPlotStr(idx,:), shading2fast(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
% end 
% ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); 
% set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)
% 
% figure; hold on; 
% title('Fast Power Spectrum (TH)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
% for idx = 1:size(PowerFastPlotTH)
%     boundedline(PSDstruct.freqs_fast, PowerFastPlotTH(idx,:), shading3fast(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
% end 
% ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); 
% set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)
% 
% % calculate the boundedline values (Slow PSD)
% n=1; 
% for idx = 5:12 
%     if ismember (idx, age)
%     PowerSlowPlotPFC(n,:) = nanmedian(PowerSlow_PFC(age==idx,:), 1); 
%     shading1slow(n,:) = nanstd(PowerSlow_PFC(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
%     PowerSlowPlotStr(n,:) = nanmedian(PowerSlow_Str(age==idx,:), 1); 
%     shading2slow(n,:) = nanstd(PowerSlow_Str(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
%     PowerSlowPlotTH(n,:) = nanmedian(PowerSlow_TH(age==idx,:), 1); 
%     shading3slow(n,:) = nanstd(PowerSlow_TH(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
%     n = n+1;
%     end 
% end 
% % plotting Slow PSD 
% figure; hold on; 
% title('Slow Power Spectrum (PFC)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
% for idx = 1:size(PowerSlowPlotPFC)
%     boundedline(PSDstruct.freqs_slow, PowerSlowPlotPFC(idx,:), shading1slow(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
% end 
% ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([0.5 5]); ylim([0 20])
% set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)
% 
% figure; hold on; 
% title('Slow Power Spectrum (Str)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
% for idx = 1:size(PowerSlowPlotStr)
%     boundedline(PSDstruct.freqs_slow, PowerSlowPlotStr(idx,:), shading2slow(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
% end 
% ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([0.5 5]); ylim([0 20])
% set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)
% 
% figure; hold on; 
% title('Slow Power Spectrum (TH)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
% for idx = 1:size(PowerSlowPlotTH)
%     boundedline(PSDstruct.freqs_slow, PowerSlowPlotTH(idx,:), shading3slow(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
% end 
% ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([0.5 5]); ylim([0 20])
% set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)
% 
