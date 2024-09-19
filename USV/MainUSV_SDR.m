%% Main USV SDR 
% SDR change during USV call period 

clear
experiments = get_experiment_redux;
experiments = experiments([256:301 324:420]);  % 256:380 [300 301 324:399]
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

folder4USVpower = 'Q:\Personal\Tony\Analysis\Results_USVpower\'; 
ch_acc = 1


for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    badch = rmmissing([experiment.NoisyCh experiment.OffCh]); 

    load([folder4USVpower experiment.animal_ID]);
    pre = USVpower.pre; 
    pre(badch, :, :) = NaN; 
    during = USVpower.during; 
    during(badch, :, :) = NaN; 
    post = USVpower.post; 
    post(badch, :, :) = NaN; 


end 