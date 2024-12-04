

clear
experiments = get_experiment_redux;
experiments = experiments(73:420);  
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup') | strcmp(extractfield(experiments, 'square'), 'ACCdeep'));

folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\Str\';
folder4SM1 = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix_plus1\Str\';

smlength = 1000000; 

i = 1; 
j = 1; 
for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 
    load([folder4SM experiment.name])
    if size(spike_matrix, 2) > smlength
        weird(i) = experiment; 
        i = i + 1; 
    end 
    clear spike_matrix 
    load([folder4SM1 experiment.name]) 
    if size(spike_matrix, 2) > smlength
        stillweird(j) = experiment; 
        j = j + 1; 
    end 
end 
