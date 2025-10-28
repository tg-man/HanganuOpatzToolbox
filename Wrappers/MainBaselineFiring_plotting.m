%% Generate baseline firing rate plot 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
% experiments = experiments(extractfield(experiments, 'IUEconstruct') == 87); 

BrainArea = 'ACC'; 
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 

% call colormap 
YlGnBu = cbrewer('seq', 'YlGnBu', 100);
Greens = cbrewer('seq', 'Greens', 100); 
Blues = cbrewer('seq', 'Blues', 100); 
Reds = cbrewer('seq', 'Reds', 100); 

fr_singlecell = []; 
agex = []; 

for exp_idx = 1: size(experiments, 2)
    experiment = experiments(exp_idx); 
      
    area_idx = find([strcmp(BrainArea, experiment.Area1) strcmp(BrainArea, experiment.Area2) strcmp(BrainArea, experiment.Area3)]); 
    
    if ~isempty(area_idx) && experiment.(['target' num2str(area_idx)]) == 1 
        load([folder4SM BrainArea filesep experiment.name]);
        len = size(spike_matrix, 2) / 1000; 
        spikes_tot = full(sum(sum(spike_matrix)));   
        fr(exp_idx) = spikes_tot / len; 
%         fr_singlecell = [fr_singlecell; sum(spike_matrix, 2) / len];
        agex = [agex; repmat(experiment.age, [size(spike_matrix, 1), 1])];
    else 
        fr(exp_idx) = NaN; 
        fr_singlecell(exp_idx) = NaN; 
    end 
end

% fr = log10(fr);
age = [experiments.age]; 

figure; violins = violinplot(fr, age, 'ViolinAlpha', 0.9, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
    violins(idx).ScatterPlot.SizeData = 12; 
end
xlabel('Age (P)'); 
ylabel('Firing Rate (Hz)'); 
xlim([0 9]); 
ylim([0.01 110]); 
set(gca, 'FontSize', 18, 'FontName', 'Arial', 'YScale', 'log', 'LineWidth', 2, 'TickDir', 'out'); 
% set(gca, 'FontSize', 18, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out'); 
title(BrainArea, 'FontSize', 18, 'FontWeight','normal', 'FontName', 'Arial'); 
set(gcf, 'Units', 'inches', 'Position', [1, 1, 6, 4]);
yticklabels({'0.01', '1', '100'});


%% simple figure; 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments(1:426);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
% experiments = experiments(extractfield(experiments, 'IUEconstruct') == 87); 

folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 

% call colormap 
YlGnBu = cbrewer('seq', 'YlGnBu', 100);
Greens = cbrewer('seq', 'Greens', 100); 
Blues = cbrewer('seq', 'Blues', 100); 
Reds = cbrewer('seq', 'Reds', 100); 

fr_acc = NaN(1, size(experiments, 2)); 
fr_str = NaN(1, size(experiments, 2)); 
ages_acc = NaN(1, size(experiments, 2)); 
ages_str = NaN(1, size(experiments, 2)); 

for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % ACC
    if experiment.target1 == 1 
        load([folder4SM 'ACC' filesep experiment.name]);
        len = size(spike_matrix, 2) / 1000; 
        spikes_tot = full(sum(sum(spike_matrix)));   
        fr_acc(exp_idx) = spikes_tot / len;
        ages_acc(exp_idx) = experiment.age;
    end 
    clear spike_matrix

    % Str 
    if experiment.target2 == 1 
        load([folder4SM 'Str' filesep experiment.name]);
        len = size(spike_matrix, 2) / 1000; 
        spikes_tot = full(sum(sum(spike_matrix)));   
        fr_str(exp_idx) = spikes_tot / len;
        ages_str(exp_idx) = experiment.age;
    end 
    clear spike_matrix
end


% plot Str 
figure; hold on; 
x = unique(rmmissing(ages_str));
for i = 1 : numel(x)
    y(i) = nanmedian(fr_acc(ages_str == x(i)));
    s(i) = nanstd(fr_acc(ages_str == x(i))) ./ sqrt(sum(ages_str == x(i)));
end 
boundedline(x, y, s, 'cmap', Reds(end,:)); 
clearvars x y s; 
% plot ACC
x = unique(rmmissing(ages_acc));
for i = 1 : numel(x)
    y(i) = nanmedian(fr_acc(ages_acc == x(i)));
    s(i) = nanstd(fr_acc(ages_acc == x(i))) ./ sqrt(sum(ages_acc == x(i)));
end 
boundedline(x, y, s, 'cmap', Blues(end,:)); 
clearvars x y s; 

xlabel('Age (P)'); ylabel('Firing Rate (Hz)'); 
set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out', 'YScale', 'log'); 
xlim([4.5 12.5]);
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end



fr2plot = [fr_acc; fr_str; fr_th]'; 
x = unique(age);
for i = 1 : numel(x)
    y(i, :) = nanmedian(fr2plot(age == x(i), :), 1);
    s(i, :) = nanstd(fr2plot(age == x(i), :), 1) ./ sqrt(sum(age == x(i)));
end 
y = y + y((y - s) < 0) + 0.00001; 
figure; hold on; 
boundedline(x, y(:, 3), s(:, 3), 'cmap', Greens(end,:)); 
boundedline(x, y(:, 1), s(:, 1), 'cmap', Blues(end,:)); 
boundedline(x, y(:, 2), s(:, 2), 'cmap', Reds(end,:)); 
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end
xlabel('Age (P)'); ylabel('Firing Rate (Hz)'); 
set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out', 'YScale', 'log'); 
xlim([4.5 12.5]);



% figure; violins = violinplot(full(fr_singlecell), agex, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
% for idx = 1:size(violins, 2)
%     violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
% end
% xlabel('Age (P)'); ylabel('single cell FR (Hz)'); xlim([0 9]); ylim([0.01 100])
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'YScale', 'log'); 
% title(BrainArea, 'FontSize', 14, 'FontWeight','bold', 'FontName', 'Arial'); 