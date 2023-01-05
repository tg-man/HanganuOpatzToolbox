%% SDR: spectral density ratio 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([10 11]); %what experiments to keepfolder4PSD = 'Q:\Personal\Tony\Analysis\Results_2Probe_PSD\'; %Fill in path where to save PSD

folder4PSD = 'Q:\Personal\Tony\Analysis\Results_3Probe_PSD\'; %Fill in path where to save PSD
folder4SDR = 'Q:\Personal\Tony\Analysis\Results_3Probe_SDR\'; %folder where SDR results are saved


% loop: go through each animal, load the PSD's, and calculate SDR 
for exp_idx = 1 : size(experiments, 2)
    
    % select specific experiment for this loop iteration: 
    experiment = experiments(exp_idx);
    
    load(strcat(folder4PSD, experiment.animal_ID, '_PFC'));  % load PSDstruct of PFC generated from last section 
    PSD_PFC = nanmedian(PSDstruct.PSD);   % select only the PSD part of the whole PSDstruct
    clear PSDstruct
    load(strcat(folder4PSD, experiment.animal_ID, '_Str'));  % do the same for Str data  
    PSD_Str = nanmedian(PSDstruct.PSD);
    clear PSDstruct
    load(strcat(folder4PSD, experiment.animal_ID, '_TH'));  % do the same for TH data  
    PSD_TH = nanmedian(PSDstruct.PSD); 
    clear PSDstruct
    
    % call function to actually calculate SDR (layer-specific) 
    disp(['calculating SDR for animal ' num2str(exp_idx)])
    SDR1 = getSDR(PSD_PFC, PSD_Str, [], []);
    SDR2 = getSDR(PSD_Str, PSD_TH, [], []);
    SDR3 = getSDR(PSD_TH, PSD_PFC, [], []);
    normSDR1 = (SDR1(:,1) - SDR1(:,end)) ./ (SDR1(:,1) + SDR1(:,end));
    normSDR2 = (SDR2(:,1) - SDR2(:,end)) ./ (SDR2(:,1) + SDR2(:,end));
    normSDR3 = (SDR3(:,1) - SDR3(:,end)) ./ (SDR3(:,1) + SDR3(:,end));
    
    % Put everythig in a struct 
    SDR.SDR1 = SDR1;
    SDR.SDR2 = SDR2;
    SDR.SDR3 = SDR3;
    SDR.normSDR1 = normSDR1;
    SDR.normSDR2 = normSDR2;
    SDR.normSDR3 = normSDR3;
    SDR.notes = '1:PFC,STR; 2:Str,TH; 3:TH,PFC.'; 

    % save the file to appropriate folder
    save(strcat(folder4SDR, experiment.animal_ID), 'SDR');
end 


%% Sup vs Deep calculations

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([25:44]); %what experiments to keepfolder4PSD = 'Q:\Personal\Tony\Analysis\Results_2Probe_PSD\'; %Fill in path where to save PSD

folder4PSD = 'Q:\Personal\Tony\Analysis\Results_2Probe_PSD\'; %Fill in path where to save PSD
folder4SDR_layers = 'Q:\Personal\Tony\Analysis\Results_2Probe_SDR_Layers\';  %folder where layer-specific SDR results are saved

for exp_idx = 1 : size(experiments, 2)
    
    % select specific experiment for this loop iteration: 
    experiment = experiments(exp_idx);    
    
    load(strcat(folder4PSD, experiment.animal_ID, '_PFC'));  % load PSDstruct of PFC generated from last section 
    PSD_PFC_sup = nanmedian(PSDstruct.PSD(1:4, :)); 
    PSD_PFC_deep = nanmedian(PSDstruct.PSD(13:16, :)); % select only the PSD part of the whole PSDstruct
    clear PSDstruct
    load(strcat(folder4PSD, experiment.animal_ID, '_Str'));  % do the same for Str data  
    PSD_Str = nanmedian(PSDstruct.PSD);
    clear PSDstruct
    
    % call function to actually calculate SDR (layer-specific) 
    disp(['calculating SDR for animal ' num2str(exp_idx)]);
    SDR1 = getSDR(PSD_PFC_sup, PSD_Str, [], []) 
    SDR2 = getSDR(PSD_PFC_deep, PSD_Str, [], [])
    normSDR1 = (SDR1(1,1) - SDR1(1,end)) / (SDR1(1,1) + SDR1(1,end))
    normSDR2 = (SDR2(1,1) - SDR2(1,end)) / (SDR2(1,1) + SDR2(1,end))
    
    
    % Put everythig in a struct 
    SDR.SDR1 = SDR1; 
    SDR.SDR2 = SDR2; 
    SDR.normSDR1 = normSDR1;
    SDR.normSDR2 = normSDR2;
    SDR.Area1 = experiment.Area1;
    SDR.Area2 = experiment.Area2; 
    SDR.notes = 'SDR1 sup, SDR2 deep'; 

    % save the file to appropriate folder
    save(strcat(folder4SDR_layers, experiment.animal_ID), 'SDR'); 
end 

%% 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments(); %what experiments to keepfolder4PSD = 'Q:\Personal\Tony\Analysis\Results_2Probe_PSD\'; %Fill in path where to save PSD

folder4PSD = 'Q:\Personal\Tony\Analysis\Results_3Probe_PSD\'; %Fill in path where to save PSD
folder4SDR = 'Q:\Personal\Tony\Analysis\Results_3Probe_SDR\'; %folder where SDR results are saved 

