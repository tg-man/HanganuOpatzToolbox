function experiments = get_experiment_redux(klusta)
% function creates the selected experiment plus correlated parameters from
% the specified excel file
% input variable optional (vector),  if not defined: all experiments are selected, 
% if defined: selected experiments will be used

if nargin < 1
    klusta = 0;
end

Path = 'Q:\Personal\Tony\Analysis\ExperimentPlan_Tony.xlsx';
ExcelSheet = 'Pooled';
xlRange = 'A1:DZ1000';
[~, ~, InfoandDevMil] = xlsread(Path, ExcelSheet, xlRange); % Import recording summary from excel sheet

[~, idxC_n_experiment] = find(strcmp(InfoandDevMil, 'n_experiment'));
[~, idxC_animalID] = find(strcmp(InfoandDevMil, 'animal_ID'));
[~, idxC_Sites] = find(strcmp(InfoandDevMil, 'Sites'));
[~, idxC_Exp_type] = find(strcmp(InfoandDevMil, 'Exp_type'));
[~, idxC_Alive_recording] = find(strcmp(InfoandDevMil, 'Alive recording'));
[~, idxC_Path] = find(strcmp(InfoandDevMil, 'Path'));
[~, idxC_Age] = find(strcmp(InfoandDevMil, 'Age'));
[~, idxC_weight] = find(strcmp(InfoandDevMil, 'Weight'));
[~, idxC_sex] = find(strcmp(InfoandDevMil, 'sex'));
[~, idxC_IUEconstruct] = find(strcmp(InfoandDevMil, 'construct'));
[~, idxC_IUEarea] = find(strcmp(InfoandDevMil, 'target'));
[~, idxC_IUEage] = find(strcmp(InfoandDevMil, 'age (E)'));
% [~, idxC_HPreversal] = find(strcmp(InfoandDevMil, 'HP reversal'));
% [~, idxC_ageGroup] = find(strcmp(InfoandDevMil, 'Age Group'));
[~, idxC_ramp] = find(strcmp(InfoandDevMil, 'ramp'));
[~, idxC_square] = find(strcmp(InfoandDevMil, 'square'));
[~, idxC_baseline] = find(strcmp(InfoandDevMil, 'baseline'));
% [~, idxC_PL] = find(strcmp(InfoandDevMil, 'PFC_PL'));
[~, idxC_klusta] = find(strcmp(InfoandDevMil, 'Klusta'));
[~, idxC_noisy] = find(strcmp(InfoandDevMil, 'noisy ch'));
[~, idxC_RecKeep] = find(strcmp(InfoandDevMil, 'Rec Keep'));
[~, idxC_Area1] = find(strcmp(InfoandDevMil, 'Area1'));
[~, idxC_Area2] = find(strcmp(InfoandDevMil, 'Area2'));
[~, idxC_Area3] = find(strcmp(InfoandDevMil, 'Area3'));
[~, idxC_target1] = find(strcmp(InfoandDevMil, 'target1'));
[~, idxC_target2] = find(strcmp(InfoandDevMil, 'target2'));
[~, idxC_target3] = find(strcmp(InfoandDevMil, 'target3'));
[~, idxC_Electrode1] = find(strcmp(InfoandDevMil, 'Electrode1'));
[~, idxC_DiI] = find(strcmp(InfoandDevMil, 'DiI'));
[~, idxC_USV_path] = find(strcmp(InfoandDevMil, 'USV_path'));
[~, idxC_USV] = find(strcmp(InfoandDevMil, 'USV'));
% [~, idxC_Lag_behind_ephys] = find(strcmp(InfoandDevMil, 'Lag_behind_ephys (s)'));
[~, idxC_OffCh] = find(strcmp(InfoandDevMil, 'off target ch'));

count=0;
for row = 6:1000
    if (klusta > 0 && InfoandDevMil{row,  idxC_klusta} == klusta) || klusta == 0
        if isa(InfoandDevMil{row,  idxC_n_experiment}, 'numeric') && ~isnan(InfoandDevMil{row, idxC_n_experiment})
            if isnumeric(InfoandDevMil{row, idxC_animalID})
                InfoandDevMil{row, idxC_animalID}  =  num2str(InfoandDevMil{row, idxC_animalID});
            end
            experiments(InfoandDevMil{row,  idxC_n_experiment}).animal_ID = InfoandDevMil{row,  idxC_animalID};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).Exp_type = InfoandDevMil{row,  idxC_Exp_type};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).sites = InfoandDevMil{row,  idxC_Sites};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).name = InfoandDevMil{row,  idxC_Alive_recording};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).path = InfoandDevMil{row,  idxC_Path};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).age = InfoandDevMil{row,  idxC_Age};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).weight = InfoandDevMil{row,  idxC_weight};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).sex = InfoandDevMil{row,  idxC_sex};
            try 
                experiments(InfoandDevMil{row,  idxC_n_experiment}).IUEconstruct = str2num(InfoandDevMil{row,  idxC_IUEconstruct});
            catch 
                experiments(InfoandDevMil{row,  idxC_n_experiment}).IUEconstruct = InfoandDevMil{row,  idxC_IUEconstruct};
            end 
            experiments(InfoandDevMil{row,  idxC_n_experiment}).IUEarea = InfoandDevMil{row,  idxC_IUEarea};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).IUEage = InfoandDevMil{row,  idxC_IUEage};
%             experiments(InfoandDevMil{row,  idxC_n_experiment}).AgeGroup = InfoandDevMil{row,  idxC_ageGroup};
%             experiments(InfoandDevMil{row,  idxC_n_experiment}).HPreversal = InfoandDevMil{row,  idxC_HPreversal};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).ramp = InfoandDevMil{row,  idxC_ramp};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).square = InfoandDevMil{row,  idxC_square};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).baseline = InfoandDevMil{row,  idxC_baseline};
%             experiments(InfoandDevMil{row,  idxC_n_experiment}).PL = InfoandDevMil{row,  idxC_PL};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).Klusta = InfoandDevMil{row,  idxC_klusta};
            try 
                experiments(InfoandDevMil{row,  idxC_n_experiment}).RecKeep = str2num(InfoandDevMil{row,  idxC_RecKeep});
            catch 
                experiments(InfoandDevMil{row,  idxC_n_experiment}).RecKeep = InfoandDevMil{row,  idxC_RecKeep};
            end 
            experiments(InfoandDevMil{row,  idxC_n_experiment}).Area1 = InfoandDevMil{row,  idxC_Area1};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).electrode1 = InfoandDevMil{row,  idxC_Electrode1};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).DiI = InfoandDevMil{row,  idxC_DiI};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).target1 = InfoandDevMil{row,  idxC_target1};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).Area2 = InfoandDevMil{row,  idxC_Area2};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).target2 = InfoandDevMil{row,  idxC_target2};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).Area3 = InfoandDevMil{row,  idxC_Area3};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).target3 = InfoandDevMil{row,  idxC_target3};
            try
                experiments(InfoandDevMil{row,  idxC_n_experiment}).NoisyCh = str2num(InfoandDevMil{row,  idxC_noisy});
            catch
                experiments(InfoandDevMil{row,  idxC_n_experiment}).NoisyCh = InfoandDevMil{row,  idxC_noisy};
            end
            
            try
                experiments(InfoandDevMil{row,  idxC_n_experiment}).OffCh = str2num(InfoandDevMil{row,  idxC_OffCh});
            catch 
                experiments(InfoandDevMil{row,  idxC_n_experiment}).OffCh = InfoandDevMil{row,  idxC_OffCh};
            end             
            experiments(InfoandDevMil{row,  idxC_n_experiment}).USV_path = InfoandDevMil{row,  idxC_USV_path};
%             experiments(InfoandDevMil{row,  idxC_n_experiment}).Lag_behind_ephys = InfoandDevMil{row,  idxC_Lag_behind_ephys};
            experiments(InfoandDevMil{row,  idxC_n_experiment}).USV = InfoandDevMil{row,  idxC_USV};

            
%             try
%                 experiments(InfoandDevMil{row,  idxC_n_experiment}).PL = str2num(InfoandDevMil{row,  idxC_PL});
%             end
%             try
%                 experiments(InfoandDevMil{row,  idxC_n_experiment}).HPreversal = str2num(InfoandDevMil{row,  idxC_HPreversal});
%             end
        end
    end
end