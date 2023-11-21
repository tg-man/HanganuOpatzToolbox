%% SDR: spectral density ratio 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([10 11]); %what experiments to keepfolder4PSD = 'Q:\Personal\Tony\Analysis\Results_2Probe_PSD\'; %Fill in path where to save PSD

folder4PSD = 'Q:\Personal\Tony\Analysis\Results_PSD_pWelch\'; %Fill in path where to save PSD
folder4SDR = 'Q:\Personal\Tony\Analysis\Results_SDR_pWelch\'; %folder where SDR results are saved


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

%% pWelch SDR

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments(); 
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

folder4PSD = 'Q:\Personal\Tony\Analysis\Results_PSD_pWelch\'; %Fill in path where to save PSD
folder4SDR = 'Q:\Personal\Tony\Analysis\Results_SDR_pWelch\'; %folder where SDR results are saved
ch_acc = 17:32; 
ch_accsup = 17:20; 
ch_accdeep = 29:32; 
ch_str = 1:16; 
ch_th = 33:48; 

% loop: go through each animal, load the PSD's, and calculate SDR 
for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx);

    disp(['computing SDR' num2str(exp_idx) ' / ' num2str(numel(experiments))])
    load([folder4PSD experiment.name]); 
    PSD = PSDpWelch.PSD; 

    bad_ch = rmmissing([experiment.NoisyCh,experiment.OffCh]); 
    PSD(bad_ch, :) = NaN; % Do the same here for noisy channels

    if experiment.target2 == 1 
        PSD_acc = nanmedian(PSD(ch_acc, :)); 
        PSD_accsup = nanmedian(PSD(ch_accsup, :));
        PSD_accdeep = nanmedian(PSD(ch_accdeep, :));
        PSD_str = nanmedian(PSD(ch_str, :));
        SDR_accstr = getSDR(PSD_acc, PSD_str, [], []); 
        normSDR_accstr = (SDR_accstr(:,1) - SDR_accstr(:,end)) ./ (SDR_accstr(:,1) + SDR_accstr(:,end));
        SDR_accsupstr = getSDR(PSD_accsup, PSD_str, [], []); 
        normSDR_accsupstr = (SDR_accsupstr(:,1) - SDR_accsupstr(:,end)) ./ (SDR_accsupstr(:,1) + SDR_accsupstr(:,end));
        SDR_accdeepstr = getSDR(PSD_accdeep, PSD_str, [], []); 
        normSDR_accdeepstr = (SDR_accdeepstr(:,1) - SDR_accdeepstr(:,end)) ./ (SDR_accdeepstr(:,1) + SDR_accdeepstr(:,end));   
    else 
        SDR_accstr = NaN; 
        normSDR_accstr = NaN; 
        SDR_accsupstr = NaN; 
        normSDR_accsupstr = NaN; 
        SDR_accdeepstr = NaN; 
        normSDR_accdeepstr = NaN; 
    end 

    if experiment.target3 == 1 
        PSD_acc = nanmedian(PSD(ch_acc, :));
        PSD_accsup = nanmedian(PSD(ch_accsup, :));
        PSD_accdeep = nanmedian(PSD(ch_accdeep, :));
        PSD_th = nanmedian(PSD(ch_th, :));
        SDR_accth = getSDR(PSD_acc, PSD_th, [], []); 
        normSDR_accth = (SDR_accth(:,1) - SDR_accth(:,end)) ./ (SDR_accth(:,1) + SDR_accth(:,end));
        SDR_accsupth = getSDR(PSD_accsup, PSD_th, [], []); 
        normSDR_accsupth = (SDR_accsupth(:,1) - SDR_accsupth(:,end)) ./ (SDR_accsupth(:,1) + SDR_accsupth(:,end));
        SDR_accdeepth = getSDR(PSD_accdeep, PSD_th, [], []); 
        normSDR_accdeepth = (SDR_accdeepth(:,1) - SDR_accdeepth(:,end)) ./ (SDR_accdeepth(:,1) + SDR_accdeepth(:,end));
    else 
        SDR_accth = NaN; 
        normSDR_accth = NaN; 
        SDR_accsupth = NaN; 
        normSDR_accsupth = NaN; 
        SDR_accdeepth = NaN; 
        normSDR_accdeepth = NaN; 
    end 

    % Put everythig in a struct 
    SDR.SDR_accstr = SDR_accstr; 
    SDR.normSDR_accstr = normSDR_accstr;
    SDR.SDR_accsupstr = SDR_accsupstr; 
    SDR.normSDR_accsupstr = normSDR_accsupstr;
    SDR.SDR_accdeepstr = SDR_accdeepstr; 
    SDR.normSDR_accdeepstr = normSDR_accdeepstr;
    SDR.SDR_accth = SDR_accth; 
    SDR.normSDR_accth = normSDR_accth;
    SDR.SDR_accsupth = SDR_accsupth; 
    SDR.normSDR_accsupth = normSDR_accsupth;
    SDR.SDR_accdeepth = SDR_accdeepth; 
    SDR.normSDR_accdeepth = normSDR_accdeepth;
    SDR.notes = 'computed with pWelch PSD'; 

    % save the file to appropriate folder
    save(strcat(folder4SDR, experiment.name), 'SDR');
end 

%% Plotting pwelch SDR 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments(); 
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
YlGnBu = cbrewer('seq', 'YlGnBu', 100); % call colormap 

folder4SDR = 'Q:\Personal\Tony\Analysis\Results_SDR_pWelch\'; %folder where SDR results are saved

accstr = [];
accsupstr = [];
accdeepstr = [];
accth = [];
accsupth = [];
accdeepth = [];
age = []; 

for exp_idx = 1 : numel(experiments) 
    experiment = experiments(exp_idx); 

    load([folder4SDR experiment.name]);

    accstr = [accstr; SDR.normSDR_accstr];
    accsupstr = [accsupstr; SDR.normSDR_accsupstr];
    accdeepstr = [accdeepstr; SDR.normSDR_accdeepstr];
   
    accth = [accth; SDR.normSDR_accth];
    accsupth = [accsupth; SDR.normSDR_accsupth];
    accdeepth = [accdeepth; SDR.normSDR_accdeepth];
    age = [age; experiment.age]; 

end 

figure; 
violins = violinplot(accstr, age, 'ViolinAlpha', 0.85); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
yline(0, ':k', 'LineWidth', 1.5); 
title('ACC \rightarrow Str', 'FontSize', 20, 'FontWeight','normal', 'FontName', 'Arial')
xlabel('Age (P)'); ylabel('Normalized SDR')
xlim([0.5 8.8]); ylim([-0.9 0.7]);
set(gca, 'FontName', 'Arial', 'FontSize', 20, 'TickDir', 'out', 'LineWidth', 2.8);

figure; 
violins = violinplot(accsupstr, age, 'ViolinAlpha', 0.85); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
yline(0, ':k', 'LineWidth', 1.5); 
title('ACCsup \rightarrow Str', 'FontSize', 20, 'FontWeight','normal', 'FontName', 'Arial')
xlabel('Age (P)'); ylabel('Normalized SDR')
xlim([0.5 8.8]); ylim([-0.9 0.7]);
set(gca, 'FontName', 'Arial', 'FontSize', 20, 'TickDir', 'out', 'LineWidth', 2.8);

figure; 
violins = violinplot(accdeepstr, age, 'ViolinAlpha', 0.85); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
yline(0, ':k', 'LineWidth', 1.5); 
title('ACCdeep \rightarrow Str', 'FontSize', 20, 'FontWeight','normal', 'FontName', 'Arial')
xlabel('Age (P)'); ylabel('Normalized SDR')
xlim([0.5 8.8]); ylim([-0.9 0.7]);
set(gca, 'FontName', 'Arial', 'FontSize', 20, 'TickDir', 'out', 'LineWidth', 2.8);



figure; 
violins = violinplot(accth, age, 'ViolinAlpha', 0.85); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
yline(0, ':k', 'LineWidth', 1.5); 
title('ACC \rightarrow TH', 'FontSize', 20, 'FontWeight','normal', 'FontName', 'Arial')
xlabel('Age (P)'); ylabel('Normalized SDR')
xlim([0.5 8.8]); ylim([-0.9 0.7]);
set(gca, 'FontName', 'Arial', 'FontSize', 20, 'TickDir', 'out', 'LineWidth', 2.8);

figure; 
violins = violinplot(accsupth, age, 'ViolinAlpha', 0.85); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
yline(0, ':k', 'LineWidth', 1.5); 
title('ACCsup \rightarrow TH', 'FontSize', 20, 'FontWeight','normal', 'FontName', 'Arial')
xlabel('Age (P)'); ylabel('Normalized SDR')
xlim([0.5 8.8]); ylim([-0.9 0.7]);
set(gca, 'FontName', 'Arial', 'FontSize', 20, 'TickDir', 'out', 'LineWidth', 2.8);

figure; 
violins = violinplot(accdeepth, age, 'ViolinAlpha', 0.85); 
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
yline(0, ':k', 'LineWidth', 1.5); 
title('ACCdeep \rightarrow TH', 'FontSize', 20, 'FontWeight','normal', 'FontName', 'Arial')
xlabel('Age (P)'); ylabel('Normalized SDR')
xlim([0.5 8.8]); ylim([-0.9 0.7]);
set(gca, 'FontName', 'Arial', 'FontSize', 20, 'TickDir', 'out', 'LineWidth', 2.8);
