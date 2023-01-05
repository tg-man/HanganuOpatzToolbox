%% Basic LFP properties 
clear
% load experiments and generic stuff

experiments = get_experiment_redux; 
experiments = experiments([45:63]); % what experiments to keep

% folders to grab various results
folder4osc = 'Q:\Personal\Tony\Analysis\Results_3Probe_osc_test\';
folder4PSD = 'Q:\Personal\Tony\Analysis\Results_3Probe_PSD\';

% initialize variables
time_in_osc = NaN(size(experiments, 2), 2);
num_osc = time_in_osc;
duration = time_in_osc;
amplitude = time_in_osc;
age = NaN(size(experiments, 2), 1);
Power_PFC = NaN(numel(experiments), 108); % originally 152
Power_Str = Power_PFC; 
Power_TH = Power_PFC; 
PowerSlow_PFC = NaN(numel(experiments), 98); 
PowerSlow_Str = PowerSlow_PFC; 
PowerSlow_TH = PowerSlow_PFC; 
PowerFast_PFC = NaN(numel(experiments), 244); % look at PSDstruct for position 2. originally 502 for 50 high cut
PowerFast_Str = PowerFast_PFC; 
PowerFast_TH = PowerFast_PFC; 

% compute all sort of computations, on an experiment by experiment basis
for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
     % load oscillations
    load(strcat(folder4osc, experiment.animal_ID, '_PFC'));
    timestamps = extractfield(oscillations, 'timestamps');
    time_in_osc(exp_idx,1) = sum(oscillations.durations) ./ oscillations.len_rec;
    num_osc(exp_idx,1) = size(oscillations.durations, 1) / (oscillations.len_rec / (60*200));
    duration(exp_idx,1) = nanmedian(oscillations.durations / 200); %in seconds
    amplitude(exp_idx,1) = nanmedian(oscillations.peakAbsPower); 
    clear oscillations 
    load(strcat(folder4osc, experiment.animal_ID, '_Str'));
    timestamps = extractfield(oscillations, 'timestamps');
    time_in_osc(exp_idx,2) = sum(oscillations.durations) ./ oscillations.len_rec;
    num_osc(exp_idx,2) = size(oscillations.durations, 1) / (oscillations.len_rec / (60*200));
    duration(exp_idx,2) = nanmedian(oscillations.durations / 200); %in seconds
    amplitude(exp_idx,2) = nanmedian(oscillations.peakAbsPower); 
    clear oscillations 
    load(strcat(folder4osc, experiment.animal_ID, '_TH'));
    timestamps = extractfield(oscillations, 'timestamps');
    time_in_osc(exp_idx,3) = sum(oscillations.durations) ./ oscillations.len_rec;
    num_osc(exp_idx,3) = size(oscillations.durations, 1) / (oscillations.len_rec / (60*200));
    duration(exp_idx,3) = nanmedian(oscillations.durations / 200); %in seconds
    amplitude(exp_idx,3) = nanmedian(oscillations.peakAbsPower); 
    
    % load PSD 
    load(strcat(folder4PSD, experiment.animal_ID, '_PFC'));
    Power_PFC(exp_idx, end - size(PSDstruct.PSD, 2) + 1 : end) = nanmedian(PSDstruct.PSD);
    PowerSlow_PFC(exp_idx, end - size(PSDstruct.PSD_slow, 2) + 1 : end) = nanmedian(nanmedian(PSDstruct.PSD_slow), 3);
    PowerFast_PFC(exp_idx, end - size(PSDstruct.PSD_fast, 2) + 1 : end) = nanmedian(nanmedian(PSDstruct.PSD_fast), 3);
    clear PSDstruct 
    load(strcat(folder4PSD, experiment.animal_ID, '_Str'));
    Power_Str(exp_idx, end - size(PSDstruct.PSD, 2) + 1 : end) = nanmedian(PSDstruct.PSD);
    PowerSlow_Str(exp_idx, end - size(PSDstruct.PSD_slow, 2) + 1 : end) = nanmedian(nanmedian(PSDstruct.PSD_slow), 3);
    PowerFast_Str(exp_idx, end - size(PSDstruct.PSD_fast, 2) + 1 : end) = nanmedian(nanmedian(PSDstruct.PSD_fast), 3);
    clear PSDstruct 
    load(strcat(folder4PSD, experiment.animal_ID, '_TH'));
    Power_TH(exp_idx, end - size(PSDstruct.PSD, 2) + 1 : end) = nanmedian(PSDstruct.PSD);
    PowerSlow_TH(exp_idx, end - size(PSDstruct.PSD_slow, 2) + 1 : end) = nanmedian(nanmedian(PSDstruct.PSD_slow), 3);
    PowerFast_TH(exp_idx, end - size(PSDstruct.PSD_fast, 2) + 1 : end) = nanmedian(nanmedian(PSDstruct.PSD_fast), 3);
end


% plotting just for some quick checking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% plot oscillations stuff %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
YlGnBu = cbrewer('seq', 'YlGnBu', 100); % call colormap 

% Time in osc
figure; violins = violinplot(time_in_osc(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.45);hold on; 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Time in Active Periods'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Time in Active Periods', 'FontSize', 18, 'FontWeight', 'bold');

figure; hold on; 
scatter(age-0.3, time_in_osc(:,1), 'filled', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r'); 
scatter(age, time_in_osc(:,2), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b'); 
scatter(age+0.3, time_in_osc(:,3), 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g'); 
xlim([4.5 10.5]);
xline([5.5 6.5 7.5 8.5 9.5], '--'); 
legend('PFC', 'Str', 'TH','','','','','');

figure; violins = violinplot(time_in_osc(:,2), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Time in Active Periods'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Time in Active Periods (Str)', 'FontSize', 18, 'FontWeight', 'bold');

figure; violins = violinplot(time_in_osc(:,3), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Time in Active Periods'); ylim([0 1]); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Time in Active Periods (TH)', 'FontSize', 18, 'FontWeight', 'bold');

% Num of osc
figure; violins = violinplot(num_osc(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.45);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Count/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Number of Active Periods (PFC)', 'FontSize', 18, 'FontWeight', 'bold');

figure; violins = violinplot(num_osc(:,2), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Count/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Number of Active Periods (Str)', 'FontSize', 18, 'FontWeight', 'bold');

figure; violins = violinplot(num_osc(:,3), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Count/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Number of Active Periods (TH)', 'FontSize', 18, 'FontWeight', 'bold');

figure; hold on; 
scatter(age-0.3, num_osc(:,1), 'filled', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r'); 
scatter(age, num_osc(:,2), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b'); 
scatter(age+0.3, num_osc(:,3), 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g'); 
xlim([4.5 10.5]);
xline([5.5 6.5 7.5 8.5 9.5], '--'); 
legend('PFC', 'Str', 'TH','','','','','');
xlabel('Age (P)'); ylabel('Count/min'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Number of Active Periods', 'FontSize', 18, 'FontWeight', 'bold');

% Dura of osc
figure; violins = violinplot(duration(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.45);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Duration of Active Periods (PFC)', 'FontSize', 18, 'FontWeight', 'bold');

figure; violins = violinplot(duration(:,2), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Duration of Active Periods (Str)', 'FontSize', 18, 'FontWeight', 'bold');

figure; violins = violinplot(duration(:,3), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Duration of Active Periods (TH)', 'FontSize', 18, 'FontWeight', 'bold');


figure; hold on; 
scatter(age-0.3, duration(:,1), 'filled', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r'); 
scatter(age, duration(:,2), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b'); 
scatter(age+0.3, duration(:,3), 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g'); 
xlim([4.5 10.5]); ylim([0.5 20]);
xline([5.5 6.5 7.5 8.5 9.5], '--'); 
legend('PFC', 'Str', 'TH','','','','','');
xlabel('Age (P)'); ylabel('Duration (s)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Duration of Active Periods', 'FontSize', 18, 'FontWeight', 'bold');
set(gca, 'YScale', 'log');


% Amp of osc
figure; violins = violinplot(amplitude(:,1), age, 'ViolinAlpha', 0.7, 'Width', 0.45);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Amplitude of Active Periods (PFC)', 'FontSize', 18, 'FontWeight', 'bold');

figure; violins = violinplot(amplitude(:,2), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Amplitude of Active Periods (Str)', 'FontSize', 18, 'FontWeight', 'bold');

figure; violins = violinplot(amplitude(:,3), age,  'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
end
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Amplitude of Active Periods (TH)', 'FontSize', 18, 'FontWeight', 'bold');

figure; hold on; 
scatter(age-0.3, amplitude(:,1), 'filled', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r'); 
scatter(age, amplitude(:,2), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b'); 
scatter(age+0.3, amplitude(:,3), 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g'); 
xlim([4.5 10.5]); ylim([100 1050]);
xline([5.5 6.5 7.5 8.5 9.5], '--'); 
legend('PFC', 'Str', 'TH','','','','','');
xlabel('Age (P)'); ylabel('Amplitude (\muV)'); set(gca, 'FontSize', 16, 'FontName', 'Arial')
title('Amplitude of Active Periods', 'FontSize', 18, 'FontWeight', 'bold');
set(gca, 'YScale', 'log');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% plot power stuff %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%calculate the boundedline values (baseline PSD) 
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
figure; hold on; 
for idx = 1:size(PowerPlotPFC)
    plot(PSDstruct.freqs, PowerPlotPFC(idx,:), 'Color',  YlGnBu(round(100/8*idx),:)); 
%     boundedline(PSDstruct.freqs, PowerPlotPFC(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));   
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([1 50]); ylim([0.01 20]);
title('Baseline Power Spectrum (PFC)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

figure; p = pcolor(PSDstruct.freqs, 5:10, PowerPlotPFC); colormap jet; colorbar; 
p.EdgeColor = 'none'; 
ylabel('Frequency (Hz)'); xlabel('Age (P)'); xlim([1 50]);
title('Baseline Power Spectrum (PFC)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
set(gca, 'XScale', 'log', 'FontSize', 16)

figure; hold on; 
title('Baseline Power Spectrum (Str)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(PowerPlotStr)
    plot(PSDstruct.freqs, PowerPlotStr(idx,:), 'Color',  YlGnBu(round(100/8*idx),:)); 
%     boundedline(PSDstruct.freqs, PowerPlotStr(idx,:), shading2(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));    
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([1 50]); ylim([0.01 20]);
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

figure; hold on; 
title('Baseline Power Spectrum (TH)', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(PowerPlotTH)
    plot(PSDstruct.freqs, PowerPlotTH(idx,:), 'Color',  YlGnBu(round(100/8*idx),:)); 
%     boundedline(PSDstruct.freqs, PowerPlotTH(idx,:), shading3(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));    
end 
ylabel('Power (\muV^2)'); xlabel('Frequency (Hz)'); xlim([1 50]); ylim([0.01 20]);
set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 16)

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

%% Loading & plotting SDR stuff (non-layer specific) 

clear; 
experiments = get_experiment_redux; % load experiments and generic stuff
experiments = experiments (); %what experiments to keep 
YlGnBu = cbrewer('seq', 'YlGnBu', 100); %call colormap 

folder4SDR = 'Q:\Personal\Tony\Analysis\Results_3Probe_SDRnoCAR\'; 

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
    % load SDR
    load(strcat(folder4SDR, experiment.animal_ID));
    SDRnorm1(exp_idx) = SDR.normSDR1; 
    SDRnorm2(exp_idx) = SDR.normSDR2; 
    SDRnorm3(exp_idx) = SDR.normSDR3; 
%     SDR(exp_idx, 1) = SDR.SDR(1,1); 
%     SDR2plot(exp_idx, 2) = SDR.SDR(1,end);  
end

SDRnorm1 = SDRnorm1'; 
SDRnorm2 = SDRnorm2'; 
SDRnorm3 = SDRnorm3'; 

figure; set(gcf, 'Position', [100 100 900 400]);
subplot(131); 
xlabel('Age (P)'); ylabel('Normalized SDR'); 
violins = violinplot(SDRnorm1, age, 'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:range(age)+1
    violins(idx).ViolinColor = YlGnBu(round(100/6*idx),:);
%     violins(n).ScatterPlot.MarkerEdgeColor = ;
%     violins(n).ScatterPlot.MarkerFaceColor = colormap(n,:);
end % colormap
ylabel('SDR (A.U.)'); xlabel('age (P)');
set(gca, 'FontSize', 16, 'FontName', 'Arial'); title('PFC->Str'); 
subplot(132);
violins = violinplot(SDRnorm2, age, 'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:range(age)+1
    violins(idx).ViolinColor = YlGnBu(round(100/6*idx),:);
%     violins(n).ScatterPlot.MarkerEdgeColor = ;
%     violins(n).ScatterPlot.MarkerFaceColor = colormap(n,:);
end % colopmap
xlabel('Age (P)');
set(gca, 'FontSize', 16, 'FontName', 'Arial');  title('Str->TH'); 
subplot(133); 

violins = violinplot(SDRnorm3, age, 'ViolinAlpha', 0.7, 'Width', 0.45); 
for idx = 1:range(age)+1
    violins(idx).ViolinColor = YlGnBu(round(100/6*idx),:);
%     violins(n).ScatterPlot.MarkerEdgeColor = ;
%     violins(n).ScatterPlot.MarkerFaceColor = colormap(n,:);
end % colopmap 
xlabel('Age (P)');
set(gca, 'FontSize', 16, 'FontName', 'Arial'); title('TH->PFC'); 
sgtitle('Normalized SDR over Age', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial'); 



% figure; set(gcf, 'Position', [100 100 400 400]);
% violins = violinplot(SDR2plot, 2, 'ViolinAlpha', 0.7, 'Width', 0.45); 
% title('Spectral Density Ratio', 'FontSize', 28, 'FontWeight', 'bold', 'FontName', 'Arial'); 
% xticklabels({strcat(SDR.Area1, ' => ', ' ', SDR.Area2), strcat(SDR.Area2, ' => ', ' ', SDR.Area1)}); 
% ylabel('SDR'); 
% set(gca, 'FontSize', 20, 'FontName', 'Arial');


%% Loading & plotting SDR stuff (freq specific) 

clear; 
experiments = get_experiment_redux; % load experiments and generic stuff
experiments = experiments(); %what experiments to keep 
YlGnBu = cbrewer('seq', 'YlGnBu', 100); %call colormap 

folder4SDR = 'Q:\Personal\Tony\Analysis\Results_3Probe_SDR_freqs\'; 

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
    % load SDR
    load(strcat(folder4SDR, experiment.animal_ID));
    SDRnorm1(exp_idx,:) = SDR.normSDR1; 
    SDRnorm2(exp_idx,:) = SDR.normSDR2; 
    SDRnorm3(exp_idx,:) = SDR.normSDR3; 
end
age = age'; 
 
% calculate plotting values 
n = 1
for idx = 5:12 
    if ismember(idx, age)
        SDRnorm1plot(n,:) = nanmedian(SDRnorm1(age==idx,:),1); 
        shading1(n,:) = nanstd(SDRnorm1(age==idx,:), [], 1) ./ sqrt(nnz(age==idx)); 
        SDRnorm2plot(n,:) = nanmedian(SDRnorm2(age==idx,:),1);
        shading2(n,:) = nanstd(SDRnorm2(age==idx,:), [], 1) ./ sqrt(nnz(age==idx)); 
        SDRnorm3plot(n,:) = nanmedian(SDRnorm3(age==idx,:),1); 
        shading3(n,:) = nanstd(SDRnorm3(age==idx,:), [], 1) ./ sqrt(nnz(age==idx)); 
        n = n+1
    end 
end 
freq_bins = [1:1:100];

figure; hold on; 
for idx = 1:size(SDRnorm1plot)
    boundedline(freq_bins, SDRnorm1plot(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
end 
set(gca, 'XScale', 'log', 'FontSize', 16, 'FontName', 'Arial'); 
ylabel('normalized SDR (A.U.)'); xlabel('Frequency (Hz)'); xlim([1 50]); 
title('SDR: PFC->Str', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');

figure; hold on; 
for idx = 1:size(SDRnorm2plot)
    boundedline(freq_bins, SDRnorm2plot(idx,:), shading2(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
end 
set(gca, 'XScale', 'log', 'FontSize', 16, 'FontName', 'Arial');
ylabel('normalized SDR (A.U.)'); xlabel('Frequency (Hz)') ; xlim([1 50]); 
title('SDR: Str->TH', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');

figure; hold on; 
for idx = 1:size(SDRnorm3plot)
    boundedline(freq_bins, SDRnorm3plot(idx,:), shading3(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
end 
set(gca, 'XScale', 'log', 'FontSize', 16, 'FontName', 'Arial');
ylabel('normalized SDR (A.U.)'); xlabel('Frequency (Hz)'); xlim([1 50]);  
title('SDR: TH->PFC', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');




%% Loading & plotting SDR stuff (layer specific) 

clear; 
experiments = get_experiment_redux; % load experiments and generic stuff
experiments = experiments (); %what experiments to keep 

folder4SDR = 'Q:\Personal\Tony\Analysis\Results_2Probe_SDR_Layers\'; 

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
    % load SDR
    load(strcat(folder4SDR, experiment.animal_ID));
    SDR2plot(exp_idx, 1) = SDR.SDR1(1,1); 
    SDR2plot(exp_idx, 2) = SDR.SDR2(1,1);  
    SDR2plot(exp_idx, 3) = SDR.SDR1(1,end); 
    SDR2plot(exp_idx, 4) = SDR.SDR2(1,end); 
end

figure; set(gcf, 'Position', [100 100 500 400]);
violins = violinplot(SDR2plot, 2, 'Width', 0.45);
violins(1).ViolinColor = [1 0.375 0]
violins(1).ViolinAlpha = 0.5
violins(2).ViolinColor = [1 0.75 0]
violins(2).ViolinAlpha = 0.5
violins(3).ViolinColor = [0.5 0 1]
violins(3).ViolinAlpha = 0.5
violins(4).ViolinColor = [0.9 0 1]
violins(4).ViolinAlpha = 0.5
title('Layer-specific SDR', 'FontSize', 28, 'FontWeight', 'bold', 'FontName', 'Arial'); 
% xticklabels({strcat(SDR.Area1, ' => ', ' ', SDR.Area2), strcat(SDR.Area2, ' => ', ' ', SDR.Area1)}); 
ylabel('SDR (A.U.)'); ylim([0 2.2]); set(gca, 'FontSize', 20, 'FontName', 'Arial')

%% Plot Coherence stuff 

clear; 
experiments = get_experiment_redux; % load experiments and generic stuff
experiments = experiments(); %what experiments to keep 

folder4Coh = 'Q:\Personal\Tony\Analysis\Results_3Probe_Coh\'; 

YlGnBu = cbrewer('seq', 'YlGnBu', 100);

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
    % load coherence
    % 1 - PFC and Str
    load(strcat(folder4Coh, experiment.animal_ID, '_PFC_Str'));
    coh1(exp_idx, :) = CoherenceStuff.Coherency; 
    coh1ref(exp_idx, :) = CoherenceStuff.CohyShuff; 
    clear CoherenceStuff 
    
    % 2 - PFC and TH
    load(strcat(folder4Coh, experiment.animal_ID, '_PFC_TH'));
    coh2(exp_idx, :) = CoherenceStuff.Coherency; 
    coh2ref(exp_idx, :) = CoherenceStuff.CohyShuff; 
    clear CoherenceStuff
    
    % 3 - Str and TH
    load(strcat(folder4Coh, experiment.animal_ID, '_Str_TH'));
    coh3(exp_idx, :) = CoherenceStuff.Coherency; 
    coh3ref(exp_idx, :) = CoherenceStuff.CohyShuff; 

    if exp_idx == size(experiments, 2) 
        freqs2plot = CoherenceStuff.freqs; 
        age(exp_idx) = experiment.age; 
    end 
    clear CoherenceStuff
end
age = age'; 

%calculate the boundedline values 
n=1; 
for idx = 5:12 
    if ismember (idx, age)
    coh1plot(n,:) = nanmedian(coh1(age==idx,:), 1); 
    shading1(n,:) = nanstd(coh1(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    coh2plot(n,:) = nanmedian(coh2(age==idx,:), 1); 
    shading2(n,:) = nanstd(coh2(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    coh3plot(n,:) = nanmedian(coh3(age==idx,:), 1); 
    shading3(n,:) = nanstd(coh3(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    n = n+1
    end 
end 

% actually plotting
figure; hold on; 
title('Coherence: PFC-Str', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(coh1plot)
    boundedline(freqs2plot, coh1plot(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));    
end 
xlim([2 45]); ylabel('Imag. Coh. (A.U.)'); xlabel('Frequency (Hz'); ylim([0 0.5]); set(gca, 'FontSize', 16)
boundedline(freqs2plot, nanmedian(coh1ref, 1), nanstd(coh1ref, [], 1) ./ sqrt(size(age,1)), ':k'); 

figure; hold on; 
title('Coherence: PFC-TH', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(coh1plot)
    boundedline(freqs2plot, coh2plot(idx,:), shading2(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));     
end
xlim([2 45]);  xlabel('Frequency (Hz)'); ylabel('Imag. Coh. (A.U.)'); ylim([0 0.45]); set(gca, 'FontSize', 16)
boundedline(freqs2plot, nanmedian(coh2ref, 1), nanstd(coh2ref, [], 1) ./ sqrt(size(age,1)), ':k'); 

figure; hold on; 
title('Coherence: Str-TH', 'FontSize', 24, 'FontWeight', 'bold', 'FontName', 'Arial');
for idx = 1:size(coh1plot)
    boundedline(freqs2plot, coh3plot(idx,:), shading3(idx,:), 'cmap', YlGnBu(round(100/5*idx),:));   
end 
xlim([2 45]); xlabel('Frequency (Hz)'); ylabel('Imag. Coh. (A.U.)'); ylim([0 0.35]); set(gca, 'FontSize', 16)
boundedline(freqs2plot, nanmedian(coh3ref, 1), nanstd(coh3ref, [], 1) ./ sqrt(size(age,1)), ':k'); 



