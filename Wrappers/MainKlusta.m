
% This is a master script that runs the spike sorting algorithm klusta 
% (https://klusta.readthedocs.io/en/latest/) in a format that is friendly 
% to the neuralynx format and the way we save our recordings

%% load experiments and make animals (instead of experiment) the unit on which to sort

clear all
klusta = 1;
common_average_reference = 1; 
experiments = get_experiment_redux(klusta);
experiments = experiments([146:157]);
% experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto')); 
cores = 4; 

PRMfolder = 'C:\Klusta\PRM\3Probe\'; % main folder in which you store your PRM files 
                                    % (which then are in an area-specific and animal-specific subfolder, full path constructed in the loop)

DATfolder = 'Q:/Personal/Tony/Analysis/Results_3Probe_DAT/'; % folder in which your .DAT and .PRB files will be saved 
                                                                    % / slash direction is important in this line. Don't change!
                                                                    % (better be on Q, unless you have a lot of space 
                                                                    % on your disk)
                                    
probetypes = {'4shank', '16_50m'}; % select the probe that you used for your experiments 
                                   % probes currently available are '4shank' and '16_50m'

BrainAreas = {'ACC','Str','TH3'}; % Brain area iterable: {'ACC','PL','Str','TH3'}

% this part here follows the rationale of having multiple recordings 
% ("experiment" in the jergon of get_experiment_redux) from the same
% animal (i.e. a long opto experiment that was subdivided in
% multiple shorter recordings). This piece of code groups such recordings
% all together so that they can be spike-sorted all at the same time.
% If this is not the case for you, you can rearrange it to run over single
% recordings ("experiments") instead. 


%% create PRB, PRM and DAT files

% creates PRB and PRM files and puts them into appropriate folders. Since
% the python shell only runs on files that are on C:/, the PRMfolder has 
% to be on C:/. However, since the output files are quite big, the 
% folder2save (where they end up) should better be on Q:/, unless you are 
% just trying out stuff and have space on your local disk. In this case, 
% having the files on your disk will significantly speed up the whole 
% process.

% The PRB file is a file that describes the geometry of the probe

% The PRM file is a file that specifies your preferences for the spike
% sorting process and where to find all the relevant files

% The DAT file is the format in which the recording will be read by the 
% sorting algorithm

% double for loop to go through 1. brain areas and 2. animals
for idx_area = 1 : numel(BrainAreas)
    BrainArea = BrainAreas{idx_area};
    disp(['writing brain area ' BrainArea]) 
    if strcmp(BrainArea, 'ACC') || strcmp(BrainArea, 'PL')
        channels = 17 : 32; % select the channels that you want to spike sort (as they are named in the neuralynx format)
        probetype = probetypes{1};
        TH_mode = 0;
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area1'), BrainArea) & extractfield(experiments, 'target1') == 1); 
    elseif strcmp(BrainArea, 'Str')
        channels = 1 : 16; 
        probetype = probetypes{2};
        TH_mode = 0; 
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area2'), BrainArea) & extractfield(experiments, 'target2') == 1);
    elseif strcmp(BrainArea, 'TH3')
        channels = 33 : 48;
        probetype = probetypes{2};
        TH_mode = 1; % use 1 when sorting TH data; use 0 for other brain areas 
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area3'), BrainArea(1:end-1)) & extractfield(experiments, 'target3') == 1);
    end 
    
    % get a list of unique animals numbers 
    animals = extractfield(experiments2run, 'animal_ID');
    animals = animals(~cellfun('isempty', animals));
    animals = unique(cellfun(@num2str, animals, 'un', 0));
    
    % looping over animals to generate files 
    parfor (idx_animal = 1 : length(animals), cores)
        disp(['writing animal number ', num2str(idx_animal)])
        animal = animals{idx_animal};
        exp_idx = find(strcmp(extractfield(experiments2run, 'animal_ID'), animal),1);
        broken_channels = experiments2run(exp_idx).NoisyCh; 
        broken_channels = intersect(channels, broken_channels);

        % create PRB, DAT, and PRM fiels from neuralynx files
        DATfolder_animal = [DATfolder BrainArea '/' animal]; % slash direction is important here! Don't use filesep!
        PRB2folder(probetype, DATfolder_animal)
        nlx2DAT(animal, experiments2run, channels, broken_channels, DATfolder_animal, common_average_reference)
        
        PRMfolder_animal = strcat(PRMfolder, BrainArea, filesep, animal);
        PRM2folder(animal, DATfolder_animal, PRMfolder_animal, TH_mode);
    end  
    
    % create BAT file 
    % A BAT file is a script in lynux. Running klusta with a BAT file permits
    % you to run it in batch mode, without having to go through a python
    % shell.

    % also loop over brain areas here! 
    BATfolder = ['C:\Klusta\BAT files\' BrainArea '\']; %change path for each brain area
    disp(['generating BAT files for ' BrainArea]); 
    createBAT(animals, BATfolder, [PRMfolder BrainArea]) % CHANGE ONE PATH INSIDE!!!   
end


