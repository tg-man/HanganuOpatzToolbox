%% generate stimulation property files for python 

clear
% get experiments
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);
experiments = experiments(strcmp({experiments.Exp_type}, 'opto'));

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_StimProp\CSVs\'; 

stims = []; 

for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 
    % load stim prop file
    load([folder4stim experiment.name '_StimulationProperties_raw.mat']);
    ramps = StimulationProperties_raw(strcmp(StimulationProperties_raw(:, 8), 'ramp'), :);
%     ramps = ramps(1:30, :);
    start = round(cell2mat(ramps(1, 1)) / 3.2); 
    stop = round(cell2mat(ramps(end, 2)) / 3.2); 


    % save in table 
    mouse = {experiment.animal_ID}; 
    usvfile = {experiment.USV}; 
    stim = {experiment.ramp}; 
    if experiment.IUEconstruct == 59
        type = {'IUE'}; 
    elseif experiment.IUEconstruct == 87
        type = {'IUEctrl'}; 
    elseif experiment.IUEconstruct == 13 
        type = {'inj'}; 
    elseif isnan(experiment.IUEconstruct)
        type = {'ctrl'};
    else 
        type = {'exclude'};
    end 
       
    temp = [table(mouse) table(usvfile) array2table([start stop], 'VariableNames', {'start', 'stop'}) table(stim) table(type)]; 

    stims = [stims; temp]; 
    clear StimulationProperties_raw ramps start stop mouse usvfile stim type
end 

writetable(stims, [folder4stim 'allstims.csv'], 'QuoteStrings', true);
