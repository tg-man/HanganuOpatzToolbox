%% Main Opto sig units 
%% Ramp section 

clear
experiments = get_experiment_redux;
experiments = experiments([80:145]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59);
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
save_data = 1;
repeatCalc = 0;
folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_stim\';
folder4matrix = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\'; 
folder4pulses = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesPulse\'; 
folder4ramps = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesRamp_shift\'; 
BrainAreas = {'Str','TH3'};%{'ACC','PL','Str','TH3'}; 
p_threshold = 0.05; 


for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 
    
    for area_idx = 1 : size(BrainAreas, 2) 
        BrainArea = char(BrainAreas(area_idx)); 
        
        % load ramp matrix 
        if experiment.(['target' num2str(area_idx + 1)]) == 1
            load([folder4ramps, BrainArea, '\', experiment.name, '.mat'])
            propsigmod(exp_idx, area_idx) = sum(SUAdata_ramp.pvalue < p_threshold) / size(SUAdata_ramp.pvalue, 2); 
            
        elseif experiment.(['target' num2str(area_idx + 1)]) == 0 
            propsigmod(exp_idx, area_idx) = NaN; 
            
        end        
    end    
end 


figure; set(gcf,'Position',[100 100 400 500])
plot(1, propsigmod(:,1), '.k', 'MarkerSize', 15); hold on; 
plot(2, propsigmod(:,2), '.k', 'MarkerSize', 15);
plot([1,2], propsigmod, 'k') 
xlim([0.5 2.5]); 
set(gca, 'TickDir', 'out', 'FontSize', 16) 
title('sig mod unit', 'Fontsize', 16) 
ylabel('proportion'); xticklabels({'', 'Str', '', 'TH'}) 

%% Pulse section 

clear
experiments = get_experiment_redux;
experiments = experiments([80:145]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59);
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));
save_data = 1;
repeatCalc = 0;
folder4pulses = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesPulse\';
BrainAreas = {'Str','TH3'};%{'ACC','PL','Str','TH3'}; 
p_threshold = 0.05; 

pre_stim = 395 : 495; % in ms, pulse format
post_stim = 500 : 600; % in ms, pulse format
idx = 1;

propsigmod = NaN(length(experiments),2); 

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 
    animal{idx} = experiment.animal_ID; 
    idx = idx + 1; 
    
    for area_idx = 1 : size(BrainAreas, 2) 
        BrainArea = char(BrainAreas(area_idx)); 
        
        % load ramp matrix 
        if experiment.(['target' num2str(area_idx + 1)]) == 1
            load([folder4pulses, BrainArea, '\', experiment.name, '.mat'])
            
            SUAdata = SUAdata_pulses.pulse_spike_matrix15;
            
            % calculate stuff 
            pre = sum(sum(SUAdata(:, :, pre_stim), 3));
            post = sum(sum(SUAdata(:, :, post_stim), 3));
            pre_single_pulse = sum(SUAdata(:, :, pre_stim), 3); 
            post_single_pulse = sum(SUAdata(:, :, post_stim), 3); 
            for unit = 1 : numel(pre) 
                pvalue(unit) = signrank(pre_single_pulse(:, unit), post_single_pulse(:, unit)); 
            end 
            
            spikecountpre(exp_idx, area_idx) = sum(pre); 
            spikecountpost(exp_idx, area_idx) = sum(post);
                        
            propsigmod(exp_idx, area_idx) = sum(pvalue < p_threshold) / size(pvalue, 2); 
            OMI = (post - pre) ./ (post + pre); 
            
        elseif experiment.(['target' num2str(area_idx + 1)]) == 0 
            propsigmod(exp_idx, area_idx) = NaN; 
            spikecountpre(exp_idx, area_idx) = NaN; 
            spikecountpost(exp_idx, area_idx) = NaN; 
            
        end 
        clear pvalue 
    end    
end 


figure; set(gcf,'Position',[100 100 400 500])
plot(1, propsigmod(:,1), '.k', 'MarkerSize', 15); hold on; 
plot(2, propsigmod(:,2), '.k', 'MarkerSize', 15);
plot([1,2], propsigmod, 'k') 
xlim([0.5 2.5]); 
set(gca, 'TickDir', 'out', 'FontSize', 16) 
title('sig mod unit', 'Fontsize', 16) 
ylabel('proportion'); xticklabels({'', 'Str', '', 'TH'}) 





