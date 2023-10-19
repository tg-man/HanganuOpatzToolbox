clear
experiments = get_experiment_redux;
experiments = experiments([73:233]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'sites'), '3site'));
StimArea = 'ACCsup'; 
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), StimArea)| strcmp(extractfield(experiments, 'square'), StimArea));
% experiments = experiments(extractfield(experiments, 'IUEconstruct') == 87);
experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct')));

save_data = 1;
repeatCalc = 0;
folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_stim\';
folder4matrix = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\';
folder4pulses = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesPulse\';
folder4ramps = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesRamp_shift\';
BrainAreas = {'Str','TH'}; %{'ACC','PL','Str','TH3'};

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
animal_str = []; 
age_str = []; 
animal_th = []; 
age_th = []; 

pre_stim = 1 : 3000; % in ms, ramp format
stim = 3001 : 6000; % in ms, ramp format
post_stim = 7001 : 10000; % in ms, ramp format
idx = 1;

for animal_idx = 1 : length(experiments) 
    experiment = experiments(animal_idx); 
    animal{idx} = experiment.animal_ID; 
    idx = idx + 1; 
    
    for area_idx = 1 : numel(BrainAreas); 
        RespArea = BrainAreas{area_idx}; 
        
        if (area_idx == 1 && experiment.target2 == 1) || (area_idx ==2 && experiment.target3 == 1)
            SUAdata = getRampsSpikeMatrix(experiment, save_data, repeatCalc, RespArea, [folder4matrix RespArea '\'], folder4stim, folder4ramps);
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
                    animal_str = [animal_str, repmat({experiment.animal_ID}, 1, size(OMI_animal,2))]; 
                    age_str = horzcat(age_str, repmat(experiment.age, 1, size(OMI_animal,2))); 
                    pvalue_str = horzcat(pvalue_str, pvalue_animal);
                elseif area_idx == 2
                    OMI_th = horzcat(OMI_th, OMI_animal);
                    animal_th = [animal_th, repmat({experiment.animal_ID}, 1, size(OMI_animal,2))]; 
                    age_th = horzcat(age_th, repmat(experiment.age, 1, size(OMI_animal,2))); 
                    pvalue_th = horzcat(pvalue_th, pvalue_animal); 
                end                         
            end 
        else 
            disp(['no file for ' experiment.animal_ID ' ' RespArea])
            disp(['skipped and continuing'])  
        end 

    end 
end 


% 
% OMI_str = OMI_str(~(OMI_str == 1 | OMI_str == -1))
% OMI_th = OMI_th(~(OMI_th == 1 | OMI_th == -1))

figure; set(gcf, 'position', [100 100 500 420])
violins = violinplot([OMI_str, OMI_th], [repmat({'Str'},1, length(OMI_str)), repmat({'TH'}, 1, length(OMI_th))], 'ViolinAlpha', 0.7, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]) 
% scatter(1+rand(size(OMI_str))*0.2, OMI_str, 'filled', 'MarkerFaceAlpha', 0.5); hold on; 
% scatter(2+rand(size(OMI_th))*0.2, OMI_th, 'filled', 'MarkerFaceAlpha', 0.5); 
xlim([0.5 2.5]); yline(0, ':');
ylabel('SUA MI'); xticklabels({'Str','TH'})
title('modulation index')

p_mod = ranksum(OMI_str, OMI_th)

Str = [num2cell(OMI_str'), animal_str', num2cell(age_str')]; 
TH = [num2cell(OMI_th'), animal_th', num2cell(age_th')]; 




%% Pulse section 

clear
experiments = get_experiment_redux;
experiments = experiments([80:145]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
StimArea = 'ACCsup'; 
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), StimArea)| strcmp(extractfield(experiments, 'square'), StimArea));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59);

save_data = 1;
repeatCalc = 0;
folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_stim\';
folder4matrix = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\';
folder4pulses = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesPulse\';
BrainAreas = {'Str','TH3'}; %{'ACC','PL','Str','TH3'};

pulses = [0.005, 0.015, 0.050],
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
animal_str = []; 
age_str = []; 
animal_th = []; 
age_th = []; 

pre_stim = 395 : 495; % in ms, ramp format
post_stim = 500 : 600; % in ms, ramp format
idx = 1;

for animal_idx = 1 : length(experiments) 
    experiment = experiments(animal_idx); 
    animal{idx} = experiment.animal_ID; 
    idx = idx + 1; 
    
    for area_idx = 1 : numel(BrainAreas); 
        RespArea = BrainAreas{area_idx}; 
        
        if (area_idx == 1 && experiment.target2 == 1) || (area_idx ==2 && experiment.target3 == 1)
            SUAdata = getPulsesSpikeMatrix(experiment, save_data, repeatCalc, pulses, [folder4matrix RespArea '\'], folder4stim, RespArea, folder4pulses); 
            spikes_animal = SUAdata.pulse_spike_matrix15;
            
            if numel(spikes_animal) > 0
                if size(spikes_animal, 2) > 1
                    spikes_units = squeeze(mean(spikes_animal));
                else
                    spikes_units = squeeze(mean(spikes_animal))';
                end
%               spikes_tot = cat(1, spikes_tot, spikes_units);
                pre = squeeze(sum(spikes_animal(:, :, pre_stim), 3)); % summing up all the spikes in pre_stim period
                post = squeeze(sum(spikes_animal(:, :, post_stim), 3));
                OMI_animal = nanmean((post - pre) ./ (post + pre)); % compute modulation index
                pvalue_animal = zeros(1, size(pre, 2)); % preallocate
                for unit = 1 : size(pre, 2) % calculate p value of modulation index cell by cell
                    pvalue_animal_post(unit) = signrank(pre(:, unit), post(:, unit)); % compute pvalue of "modulation index"
                end
                
                if area_idx == 1
                    OMI_str = horzcat(OMI_str, OMI_animal);
                    animal_str = [animal_str, repmat({experiment.animal_ID}, 1, size(OMI_animal,2))]; 
                    age_str = horzcat(age_str, repmat(experiment.age, 1, size(OMI_animal,2))); 
                    pvalue_str = horzcat(pvalue_str, pvalue_animal);
                elseif area_idx == 2
                    OMI_th = horzcat(OMI_th, OMI_animal);
                    animal_th = [animal_th, repmat({experiment.animal_ID}, 1, size(OMI_animal,2))]; 
                    age_th = horzcat(age_th, repmat(experiment.age, 1, size(OMI_animal,2))); 
                    pvalue_th = horzcat(pvalue_th, pvalue_animal); 
                end                         
            end 
        else 
            disp(['no file for ' experiment.animal_ID ' ' RespArea])
            disp(['skipped and continuing'])  
        end 

    end 
end 


figure;
scatter(1+rand(size(OMI_str))*0.2, OMI_str, 'filled', 'MarkerFaceAlpha', 0.5); hold on; 
scatter(2+rand(size(OMI_th))*0.2, OMI_th, 'filled', 'MarkerFaceAlpha', 0.5); 
xlim([0 3]); yline(0);
legend('str', 'th')
title('modulation index')

p_mod = ranksum(OMI_str, OMI_th)

Str = [num2cell(OMI_str'), animal_str', num2cell(age_str')]; 
TH = [num2cell(OMI_th'), animal_th', num2cell(age_th')]; 



% modulation = [nnz(OMI < 0 & pvalue < 0.01) ...
%     nnz(pvalue > 0.01) nnz(OMI > 0 & pvalue < 0.01)];
% modulation = modulation ./ length(OMI);
% figure;
% bar([modulation; nan(1, length(modulation))], 'stacked')
% set(gca,'xtick',1); xlim([0.25 1.75]);
% ylabel('Proportion'); xlabel(''); xticks(''); xticklabels('')
% title('Proportion of (un)modulated units')
% set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')