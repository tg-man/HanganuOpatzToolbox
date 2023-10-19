function [] = plotRampFiringPie(experiments, BrainArea, StimArea, folder4ramps)
%% by Tony Oct. 2023 
% plots pie charts of positively and negatively modulated units upon ramp stimulation 
% 
% inputs: 
%     - experiments: from excel list 
%     - BrainArea: string, the single units from which are plotted 
%     - StimArea: sting, where laser stim was given 
%     - folder4ramps: directory, where the ramp spike matrices live 

map4plot = viridis(100);
Gwindow = gausswin(1001, 10); % gaussian window of 1000ms with stdev of 100ms
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
save_data = 1;
spikes_tot = [];
firing_tot = [];
OMI = [];
OMIpost = [];
pvalue = [];
pvalue_post = [];
pre_stim = 1 : 3000; % in ms, ramp format
stim = 3001 : 6000; % in ms, ramp format
post_stim = 6001 : 9000; % in ms, ramp format
idx = 1;

for n_animal = 1 : length(experiments)
    experiment = experiments(n_animal);
    animal{idx} = experiment.animal_ID;
    idx = idx + 1; 
    load([folder4ramps BrainArea filesep experiment.name '.mat']);
    spikes_animal = SUAdata_ramp.ramp_spike_matrix;
    % first concatenate the spike tensor into a matrix
    spikes_convolved = reshape(permute(spikes_animal, [2 3 1]), size(spikes_animal, 2), []);
    % convolve it with a gaussian window for better corr estimation
    for unit = 1 : size(spikes_convolved, 1)
        spikes_convolved(unit, :) = conv(spikes_convolved(unit, :), Gwindow, 'same');
    end
    % reshape it back so that you have separated trials
    spikes_convolved = permute(reshape(spikes_convolved, size(spikes_animal, 2), ...
        size(spikes_animal, 3), []), [3 1 2]);
    if numel(spikes_animal) > 0
        if size(spikes_animal, 2) > 1
            spikes_units = squeeze(mean(spikes_animal));
        else
            spikes_units = squeeze(mean(spikes_animal))';
        end
        firing_units(:, 1) = log10(mean(spikes_units(:, pre_stim), 2));
        firing_units(:, 2) = log10(mean(spikes_units(:, stim), 2));
        firing_units(:, 3) = log10(mean(spikes_units(:, post_stim), 2));
        spikes_tot = cat(1, spikes_tot, spikes_units);
        firing_tot = cat(1, firing_tot, firing_units);
        pre = squeeze(sum(spikes_animal(:, :, pre_stim), 3)); % summing up all the spikes in pre_stim period
        during = squeeze(sum(spikes_animal(:, :, stim), 3));
        post = squeeze(sum(spikes_animal(:, :, post_stim), 3));
        OMI_animal = nanmean((during - pre) ./ (during + pre)); % compute modulation index
        OMI_animal_post = nanmean((post - pre) ./ (post + pre)); % compute modulation index
        pvalue_animal = zeros(1, size(pre, 2)); % preallocate
        pvalue_animal_post = zeros(1, size(pre, 2)); % preallocate
        for unit = 1 : size(pre, 2)
            pvalue_animal(unit) = signrank(pre(:, unit), during(:, unit)); % compute pvalue of "modulation index"
            pvalue_animal_post(unit) = signrank(pre(:, unit), post(:, unit)); % compute pvalue of "modulation index"
        end
        OMI = horzcat(OMI, OMI_animal); % concatenate
        pvalue = horzcat(pvalue, pvalue_animal); % concatenate
        OMIpost = horzcat(OMIpost, OMI_animal_post); % concatenate
        pvalue_post = horzcat(pvalue_post, pvalue_animal_post); % concatenate
        clear firing_units
    end
    clearvars spikes_animal
end

modpos = sum(OMI > 0 & pvalue < 0.01);
modneg = sum(OMI < 0 & pvalue < 0.01);
modinsig = sum(pvalue > 0.01);
figure; p = pie([modneg, modinsig, modpos], '%.1f%%'); 
colormap("copper");
labels = {'negatively modulated', 'non-responsive', 'positively modulated',}; 
legend(labels, 'Location', 'eastoutside', 'FontName','Arial');
p(2).FontName = 'Arial'; 
p(4).FontName = 'Arial'; 
p(6).FontName = 'Arial'; 
title([BrainArea ' units to ' StimArea ' ramp'], 'FontName', 'Arial', 'FontSize', 14); 

modpos_post = sum(OMIpost > 0 & pvalue_post < 0.01);
modneg_post = sum(OMIpost < 0 & pvalue_post < 0.01);
modinsig_post = sum(pvalue_post > 0.01);
figure; p_post = pie([modneg_post, modinsig_post, modpos_post], '%.1f%%'); 
colormap("copper");
labels = {'negatively modulated', 'non-responsive', 'positively modulated',}; 
legend(labels, 'Location', 'eastoutside', 'FontName','Arial');
p_post(2).FontName = 'Arial'; 
p_post(4).FontName = 'Arial'; 
p_post(6).FontName = 'Arial'; 
title([BrainArea ' units post ' StimArea ' ramp'], 'FontName', 'Arial', 'FontSize', 14); 

end 










