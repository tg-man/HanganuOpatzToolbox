clear
experiments = get_experiment_redux;
experiments = experiments([80:127]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
save_data = 1;
repeatCalc = 0;
folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_stim\';
folder4matrix = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\';
folder4pulses = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesPulse\';
folder4ramps = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesRamp\';
BrainAreas = {'Str','TH3'};%{'ACC','PL','Str','TH3'};

map4plot = viridis(100);
Gwindow = gausswin(1001, 10); % gaussian window of 1000ms with stdev of 100ms
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
save_data = 1;
spikes_tot = [];
firing_tot = [];
OMI_str = []; 
OMI_th = []; 
OMIpost = [];
pvalue_str = [];
pvalue_th = [];
pvalue_post = [];
pre_stim = 1 : 3000; % in ms, ramp format
stim = 4000 : 7000; % in ms, ramp format
post_stim = 7001 : 9000; % in ms, ramp format
idx = 1;

StimArea = 'ACCsup'; 
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), StimArea)| strcmp(extractfield(experiments, 'square'), StimArea));

% this loop goes through all experiments and calculate the standard OMI and
% test for significance 
for animal_idx = 1 : length(experiments) 
    experiment = experiments(animal_idx); 
    animal{idx} = experiment.animal_ID; 
    idx = idx + 1; 
    
    for area_idx = 1 : numel(BrainAreas); 
        RespArea = BrainAreas{area_idx}; 
        try 
            SUAdata = getRampsSpikeMatrix(experiment, save_data, RespArea, [folder4matrix RespArea '\'], folder4stim, folder4ramps);
            spikes_animal = SUAdata.ramp_spike_matrix;
            if numel(spikes_animal) > 0
                if size(spikes_animal, 2) > 1
                    spikes_units = squeeze(mean(spikes_animal));
                else
                    spikes_units = squeeze(mean(spikes_animal))';
                end
%               spikes_tot = cat(1, spikes_tot, spikes_units);
                pre = squeeze(sum(spikes_animal(:, :, pre_stim), 3)); % summing up all the spikes in pre_stim period
                during = squeeze(sum(spikes_animal(:, :, stim), 3));
                post = squeeze(sum(spikes_animal(:, :, post_stim), 3));
                OMI_animal = nanmean((during - pre) ./ (during + pre));  
                OMI_animal_post = nanmean((post - pre) ./ (post + pre)); % compute modulation index
                pvalue_animal = zeros(1, size(pre, 2)); % preallocate
                for unit = 1 : size(pre, 2) % calculate p value of modulation index cell by cell
                    pvalue_animal(unit) = signrank(pre(:, unit), during(:, unit)); % compute pvalue of "modulation index"
                    pvalue_animal_post(unit) = signrank(pre(:, unit), post(:, unit)); % compute pvalue of "modulation index"
                end                
                if area_idx == 1
                    OMI_str = horzcat(OMI_str, OMI_animal); 
                    pvalue_str = horzcat(pvalue_str, pvalue_animal); 
                elseif area_idx == 2
                    OMI_th = horzcat(OMI_th, OMI_animal); 
                    pvalue_th = horzcat(pvalue_th, pvalue_animal); 
                end                  
            end 
        catch 
            disp(['no file for ' experiment.animal_ID ' ' RespArea])
            disp(['skipped and continuing'])
        end 
        
    end 
end 

figure;
scatter(1+rand(size(OMI_str))*0.1, OMI_str); hold on; 
scatter(2+rand(size(OMI_th))*0.1, OMI_th); 
xlim([0 3]); 
legend('str', 'th')
title('modulation index')


figure; 
boxplot

p_mod = ranksum(OMI_str, OMI_th)
% 
% 
% modulation = [nnz(OMI < 0 & pvalue < 0.01) ...
%     nnz(pvalue > 0.01) nnz(OMI > 0 & pvalue < 0.01)];
% modulation = modulation ./ length(OMI);
% figure;
% bar([modulation; nan(1, length(modulation))], 'stacked')
% set(gca,'xtick',1); xlim([0.25 1.75]);
% ylabel('Proportion'); xlabel(''); xticks(''); xticklabels('')
% title('Proportion of (un)modulated units')
% set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')