%% Script to generate SUAinfo file
% Tony
% run this and use the output SUAinfo file for all spike analysis

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([1:44]); % what experiments to keep
save_data = 1;
cores = 4; 

BrainAreas = {'PFC','Str'}; % Brain area iterable: {'ACC','PL','Str','TH3'}

folder4PRM = 'C:\Klusta\PRM\'; % need NOT to be animal specific
folder4DAT = 'Q:\Personal\Tony\Analysis\Results_2Probe_DAT\';
folder2save = 'Q:\Personal\Tony\Analysis\Results_2Probe_SUAinfo\';

for idx_area = 1 : numel(BrainAreas)
    
    BrainArea = BrainAreas{idx_area}; %define brain area for this loop
    disp(['writing brain area ' BrainArea])
    
    % select experiments with correct targetting for this brain area
    if strcmp(BrainArea, 'ACC') || strcmp(BrainArea, 'PL') || strcmp(BrainArea, 'PFC')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area1'), BrainArea) & extractfield(experiments, 'target1') == 1); 
    elseif strcmp(BrainArea, 'Str')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area2'), BrainArea) & extractfield(experiments, 'target2') == 1);
    elseif strcmp(BrainArea, 'TH3')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area3'), BrainArea(1:end-1)) & extractfield(experiments, 'target3') == 1);
    end
    folder4PRM_area = [folder4PRM BrainArea '\']; 
    folder2save_area = [folder2save BrainArea '\'];   
    
    % get the unique animal IDs from those experiments 
    animals = extractfield(experiments2run, 'animal_ID');
    animals = animals(~cellfun('isempty', animals));
    animals = unique(cellfun(@num2str, animals, 'un', 0));
        
    parfor (idx_animal = 1 : length(animals), cores)
        
        animal = animals{idx_animal};
        % select animal specific folders
        folder4DAT_animal = [folder4DAT BrainArea '\' animal '\'];

        % functions to generate SUAinfo file 
        disp(['generating SUAinfo for animal ' num2str(idx_animal) ' out of ' num2str(size(animals,2))])
        loadKlusta(animal, folder4PRM_area, folder4DAT_animal, save_data, folder2save_area);
    end
end




