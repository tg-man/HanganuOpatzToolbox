%% use this script to generate baseline spike matrix 

clear
experiments = get_experiment_redux;
experiments = experiments([1:73]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only'));
save_data = 1;
repeatCalc = 0; 
folder4SUAinfo3 = 'Q:\Personal\Tony\Analysis\Results_3Probe_SUAinfo\';
folder4SUAinfo2 = 'Q:\Personal\Tony\Analysis\Results_2Probe_SUAinfo\';
folder4SM3 = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\';
folder4SM2 = 'Q:\Personal\Tony\Analysis\Results_2Probe_SpikeMatrix\';

% brain areas
BrainAreas = {'PFC','ACC', 'PL', 'Str','TH3'};%{'ACC','PL','Str','TH3'};

for area_idx = 1 : numel(BrainAreas)     
    
    BrainArea = BrainAreas{area_idx}; %define brain area for this loop
    disp(['writing brain area ' BrainArea])
    
    % select experiments with correct targetting for this brain area
    if strcmp(BrainArea, 'ACC') || strcmp(BrainArea, 'PL') || strcmp(BrainArea, 'PFC') 
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area1'), BrainArea) & extractfield(experiments, 'target1') == 1); 
    elseif strcmp(BrainArea, 'Str')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area2'), BrainArea) & extractfield(experiments, 'target2') == 1);
    elseif strcmp(BrainArea, 'TH3')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area3'), BrainArea(1:end-1)) & extractfield(experiments, 'target3') == 1); 
    end
    
    % going through each experiment now 
    for exp_idx = 1 : numel(experiments2run) 
        experiment = experiments2run(exp_idx);
        disp(['writing exp #' num2str(exp_idx) ' out of ' num2str(numel(experiments2run))]) 
        
        if strcmp(experiment.sites, '2site')  
            resultsKlusta = [folder4SUAinfo2 BrainArea '\'];
            SM_output = [folder4SM2 BrainArea '\']; 
        elseif strcmp(experiment.sites, '3site') 
            resultsKlusta = [folder4SUAinfo3 BrainArea '\'];
            SM_output = [folder4SM3 BrainArea '\']; 
        end 

        getSpikeMatrixHenrik(experiment, resultsKlusta, save_data, repeatCalc, SM_output);
    end 
end 


%% code to load spike matrix 

% clear
% experiments = get_experiment_redux;
% experiments = experiments([1:73 80:157]);
% experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only'));
% save_data = 1;
% repeatCalc = 0; 
% folder4SM3 = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\';
% folder4SM2 = 'Q:\Personal\Tony\Analysis\Results_2Probe_SpikeMatrix\';
% 
% for exp_idx = 1: size(experiments, 2) 
%     experiment = experiments(exp_idx);
%     
%     % check 2site vs 3site and load spike matrices from corresponding folder
%     if strcmp(experiment.sites, '2site') 
%         if experiment.target1 == 1 
%             SM_pfc = load([folder4SM2 experiment.Area1 filesep experiment.name '.mat']); 
%         end 
%         if experiment.target2 == 1 
%             SM_str = load([folder4SM2 experiment.Area2 filesep experiment.name '.mat']);  
%         end 
%     elseif strcmp(experiment.sites, '3site') 
%         if experiment.target1 == 1 
%             SM_pfc = load([folder4SM3 experiment.Area1 filesep experiment.name '.mat']); 
%         end 
%         if experiment.target2 == 1 
%             SM_str = load([folder4SM3 experiment.Area2 filesep experiment.name '.mat']);  
%         end 
%         if experiment.target3 == 1 
%             SM_th = load([folder4SM3 experiment.Area3 '3' filesep experiment.name '.mat']);  
%         end    
%     end 
%     
%     % More code here 
%     %
%     
% end 
% 
% 
% 
