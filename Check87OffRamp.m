%% check 87 off ramp 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 87); 
baselines = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
optos = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup')); 

RampSM = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesRamp\ACC\'; 
baselineSM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\ACC\'; 
folder4suainfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\ACC\'; 

pre_stim = 1 : 3000; % in ms, ramp format
stim = 3001 : 6000; % in ms, ramp format
post_stim = 6001 : 9000; % in ms, ramp format

fr_sigpost = []; 
fr_other = []; 

for exp_idx = 1 : size(optos, 2)
    opto = optos(exp_idx); 
    baseline = baselines(exp_idx); 
    load([RampSM opto.name]); 
    sig_unit_post = SUAdata_ramp.pvalue_post < 0.01 & SUAdata_ramp.OMI_post > 0 ; 

    load([folder4suainfo opto.animal_ID]); 
    for i = 1 : numel(SUAinfo) 
        if strcmp(SUAinfo{1, i}(1).file, opto.name)
            clusters = [SUAinfo{1, i}.ClusterID]; 
            clusters = clusters(sig_unit_post); 
        end 
    end 

    idx = []; 
    for j = 1 : numel(clusters) 
        idx(j) = find([SUAinfo{1, 1}.ClusterID] == clusters(j));
    end 

    load([baselineSM baseline.name]); 
    spikes_sigpost = spike_matrix(idx, :); 
    fr_sigpost_animal = sum(spikes_sigpost, 2) / (size(spikes_sigpost, 2) / 1000); 
    fr_sigpost = [fr_sigpost; fr_sigpost_animal]; 

    other = [1:size(spike_matrix, 1)];
    other(idx) = NaN; 
    other = rmmissing(other); 
    spikes_other = spike_matrix(other, :); 
    fr_other_animal = sum(spikes_other, 2) / (size(spikes_other, 2) / 1000); 
    fr_other = [fr_other; fr_other_animal]; 

end 

fr_other = full(fr_other); 
fr_sigpost = full(fr_sigpost); 

fr = log10([fr_sigpost; fr_other]); 
cate = [ones([numel(fr_sigpost), 1]); zeros([numel(fr_other), 1])]; 

figure; violinplot(fr, cate); 
xticklabels({'other units', 'off-ramp units'});
ylabel('log10 firing rate')
title('off-ramp units baseline firing')




