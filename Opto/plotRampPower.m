function [PSD_pre, PSD_half2] = plotRampPower(experiments, stimArea, ch2plot, folder2load)
% Tony 05.2023
% Adapted from Mattia 10/22
% inputs: 
%   - experiment lists 
%   - stimArea: the area where stimulation was given
%         in my case ACCsup, Str, TH
%   - plotArea: the areas to look at, in {} format 
%   - folder2load: where the output from getRampPower was saved 

% select experiment with the specificed stim area
experiments = experiments(contains(extractfield(experiments, 'ramp'), stimArea)); 
animals = unique({experiments.animal_ID});

% colormap
cmap = cbrewer('div', 'RdBu', 100);

% initialize total PSD variable 
PSD_pre = []; 
PSD_half1 = []; 
PSD_half2 = []; 
% loop through each animal 
for animal_idx = 1 : numel(animals)
    mouse = animals(animal_idx); 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse)); 

    % initialize mouse PSD variable 
    mouse_pre = []; 
    mouse_half1 = []; 
    mouse_half2 = []; 
    % loop through animal's experiment to load ramp power 
    for exp_idx = 1 : size(exp4mouse, 2) 
        experiment = exp4mouse(exp_idx); 
        % load bad channels 
        bad_ch = [experiment.NoisyCh, experiment.OffCh];
        bad_ch = bad_ch(ismember(bad_ch, ch2plot));
        % going through channels to load 
        ch_idx = 1;
        for channel = ch2plot
            load([folder2load experiment.name '\' num2str(channel)]); 
            temp_pre(:, ch_idx, :) = StimPowerRamps.Pre;
            temp_half1(:, ch_idx, :) = StimPowerRamps.Half1;
            temp_half2(:, ch_idx, :) = StimPowerRamps.Half2; 
            freqs = StimPowerRamps.freq; 
            % take out noisy and off target channels
            if ismember(channel, bad_ch)
                temp_pre(:, ch_idx, :) = NaN; 
                temp_half1(:, ch_idx, :) = NaN; 
                temp_half2(:, ch_idx, :) = NaN; 
            end 
            ch_idx = ch_idx + 1; 
        end
        mouse_pre = [mouse_pre; temp_pre]; 
        mouse_half1 = [mouse_half1; temp_half1]; 
        mouse_half2 = [mouse_half2; temp_half2]; 
        clearvars temp_pre temp_half2
    end 
    
    % trial and channel average, then put into global variable 
    PSD_pre(animal_idx, :) = nanmedian(squeeze(nanmedian(mouse_pre, 1)), 1); 
    PSD_half1(animal_idx, :) = nanmedian(squeeze(nanmedian(mouse_half1, 1)), 1); 
    PSD_half2(animal_idx, :) = nanmedian(squeeze(nanmedian(mouse_half2, 1)), 1); 
    opsin(animal_idx) = experiment.IUEconstruct; 
end 

% plot opsin group half 2 
figure;
% boundedline(freqs, nanmedian(PSD_pre(opsin==13, :), 1), nanstd(PSD_pre(opsin==13, :), 1)./sqrt(sum(opsin==13)), 'cmap', cmap(90, :)); hold on
% boundedline(freqs, nanmedian(PSD_half2(opsin==13, :), 1), nanstd(PSD_half2(opsin==13, :), 1)./sqrt(sum(opsin==13)), 'cmap', cmap(25, :));
plot(freqs, nanmedian(PSD_pre(opsin==13, :), 1)); hold on
plot(freqs, nanmedian(PSD_half2(opsin==13, :), 1));
% plot(freqs, nanmedian(PSD_half1(opsin==13, :), 1));
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines) 
    lines(i).LineWidth = 2;
end
xlim([1 49]); 
ylim([0.1 100]); 
set(gca, 'YScale', 'log'); 
box off;
legend('pre', 'half2'); 
legend boxoff; 
set(gca,'FontSize', 16, 'FontName', 'Arial', 'TickDir','out', 'LineWidth', 2); 
xlabel('Frequency (Hz)'); 
ylabel('Power (\muV^2)');
title([num2str(ch2plot(1)) ':' num2str(ch2plot(end)) ' to ' stimArea ' stim, inj']); 

% plot ctrl group 
figure;
plot(freqs, nanmedian(PSD_pre(isnan(opsin), :), 1)); hold on
plot(freqs, nanmedian(PSD_half2(isnan(opsin), :), 1)); 
% plot(freqs, nanmedian(PSD_half1(isnan(opsin), :), 1))
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines) 
    lines(i).LineWidth = 2;
end
xlim([1 49]); 
ylim([0.1 100]); 
set(gca, 'YScale', 'log'); 
box off;
legend('pre', 'half2'); 
legend boxoff; 
set(gca,'FontSize', 16, 'FontName', 'Arial', 'TickDir','out', 'LineWidth', 2); 
xlabel('Frequency (Hz)'); 
ylabel('Power (\muV^2)');
title([num2str(ch2plot(1)) ':' num2str(ch2plot(end)) ' to ' stimArea ' stim, ctrl']); 

end 