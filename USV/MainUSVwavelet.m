%% USV wavelet plot 
% wavelet workflow from Sebastian 

clear
experiments = get_experiment_redux;
experiments = experiments(256:380);  % 256:380 [300 301 324:380]

minInterSyInt = 5000; % threshold to merge USV calls together, in ms

sigparams.ch2load = 1:48; 
sigparams.cores = 6; 
sigparams.fs = 32000; % sampling rate from data
sigparams.downsampling_factor = 160; % downsample for LFP analysis
sigparams.low_cut = 1; 
sigparams.ExtractMode = 1; % extract from neuralynx into matlab

repeat_calc = 0; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_USVwavelet\'; 

% get unique animal numbers 
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

%% calculate one animal at a time 

for animal_idx = 1 : size(animals, 2) 
    % get animal number and all experiments for this animal 
    animal = animals{animal_idx}; 
    experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal)); 

    USVwavelet = getUSVwavelet(experiments4mouse, minInterSyInt, sigparams, repeat_calc, folder2save); 
end 

%% plotting section 

plot4acc = []; 
plot4str = []; 
plot4th = []; 

for animal_idx = 1 : size(animals, 2) 
    % get animal number and all experiments for this animal 
    animal = animals{animal_idx}; 
    load([folder2save animal]);

    if isfield(USVwavelet, 'freqs') % check struct 
        % remove data from bad channels
        experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal));
        badch = [experiments4mouse(1).OffCh experiments4mouse(1).NoisyCh];
        for idx = 1: numel(badch)
            USVwavelet.(['ch' num2str(badch(idx))])(:, :) = NaN; 
        end 
    
        % average across channel in each brain area, ACC
        wavelet_acc = []; 
        for ch = 17:32
            wavelet_acc = cat(3, wavelet_acc, USVwavelet.(['ch' num2str(ch)]));
        end 
        wavelet_acc = nanmean(wavelet_acc, 3);
        % str
        wavelet_str = []; 
        for ch = 1:16
            wavelet_str = cat(3, wavelet_str, USVwavelet.(['ch' num2str(ch)]));
        end 
        wavelet_str = nanmean(wavelet_str, 3);
        % th
        wavelet_th = []; 
        for ch = 33:48
            wavelet_th = cat(3, wavelet_th, USVwavelet.(['ch' num2str(ch)]));
        end 
        wavelet_th = nanmean(wavelet_th, 3);
    
        % populate plotting vector, freq X time X animals 
        plot4acc = cat(3, plot4acc, wavelet_acc); 
        plot4str = cat(3, plot4str, wavelet_str); 
        plot4th = cat(3, plot4th, wavelet_th);
    else 
        plot4acc(:, :, animal_idx) = NaN; 
        plot4str(:, :, animal_idx) = NaN; 
        plot4th(:, :, animal_idx) = NaN; 
    end 
end 

% average across animals 
plot4acc = nanmean(plot4acc, 3); 
plot4str = nanmean(plot4str, 3); 
plot4th = nanmean(plot4th, 3); 
% time vector 
x = linspace(-(size(plot4acc, 2) / USVwavelet.fs)/2, (size(plot4acc, 2) / USVwavelet.fs)/2, size(plot4acc, 2)); 
% ACC wavelet plot 
figure; imagesc('Xdata', x, 'YData', USVwavelet.freqs, 'CData', plot4acc); %colormap parula; 
xlim([-5 5]); ylim([1 70]); 
xticks([-4 -2 0 2 4]); xline(0, ':k', 'LineWidth', 1.5); 
xlabel('time (s)'); ylabel('freq (Hz)')
set(gca, 'FontName', 'Arial', 'FontSize', 14)
title('ACC')
% Str wavelet plot 
figure; imagesc('Xdata', x, 'YData', USVwavelet.freqs, 'CData', plot4str); colormap parula; 
xlim([-5 5]); ylim([1 70]); 
xticks([-4 -2 0 2 4]); xline(0, ':k', 'LineWidth', 1.5); 
xlabel('time (s)'); ylabel('freq (Hz)')
set(gca, 'FontName', 'Arial', 'FontSize', 14)
title('Str')
% TH 
figure; imagesc('Xdata', x, 'YData', USVwavelet.freqs, 'CData', plot4th); colormap parula; 
xlim([-5 5]); ylim([1 70]); 
xticks([-4 -2 0 2 4]); xline(0, ':k', 'LineWidth', 1.5); 
xlabel('time (s)'); ylabel('freq (Hz)')
set(gca, 'FontName', 'Arial', 'FontSize', 14)
title('TH')

% 
% t = (1:2000) ./ fs_LFP
% 
% imagesc('Xdata', 1:length(test), 'YData', freq, 'CData', abs(cfs))
% image('Xdata', 1:length(test), 'YData', freq, 'CData', abs(cfs))