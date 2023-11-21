%% use this script to generate baseline spike matrix 


clear
experiments = get_experiment_redux;
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'animal_ID'), '30061-1'));
save_data = 1;
repeatCalc = 1; 
folder4SUAinfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\';
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\';

% brain areas
BrainAreas = {'ACC','Str','TH'};%{'ACC','PL','Str','TH3'};

for area_idx = 1 : numel(BrainAreas)     
    
    BrainArea = BrainAreas{area_idx}; %define brain area for this loop
    disp(['writing brain area ' BrainArea])
    
    % select experiments with correct targetting for this brain area
    if strcmp(BrainArea, 'ACC') || strcmp(BrainArea, 'PL')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area1'), BrainArea) & extractfield(experiments, 'target1') == 1); 
    elseif strcmp(BrainArea, 'Str')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area2'), BrainArea) & extractfield(experiments, 'target2') == 1);
    elseif strcmp(BrainArea, 'TH')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area3'), BrainArea) & extractfield(experiments, 'target3') == 1); 
    end
    
    % going through each experiment now 
    for exp_idx = 1 : numel(experiments2run) 
        experiment = experiments2run(exp_idx);
        disp(['writing exp #' num2str(exp_idx) ' out of ' num2str(numel(experiments2run))]) 
        
        resultsKlusta = [folder4SUAinfo BrainArea '\'];
        SM_output = [folder4SM BrainArea '\']; 

        getSpikeMatrixHenrik(experiment, resultsKlusta, save_data, repeatCalc, SM_output);                    
    end 
end 

