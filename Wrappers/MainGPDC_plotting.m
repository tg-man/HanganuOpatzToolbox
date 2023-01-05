%% Plot outputs from gPDC calculation 

% load and save all the gPDC values, into matrices 
clear
experiments = get_experiment_redux;
experiments = experiments([45:63]); % what experiments to keep
path = 'Q:\Personal\Tony\Analysis\Results_3Probe_gPDC_coactive\';
YlGnBu = cbrewer('seq', 'YlGnBu', 100); % call colormap 

c12 = []; 
c21 = []; 
for exp_idx = 1:size(experiments,2)
    experiment = experiments(exp_idx); 
    
    % set age
    age(exp_idx) = experiment.age;

%     load(strcat(path, experiment.animal_ID, '_PFC_Str'))
%     load(strcat(path, experiment.animal_ID, '_Str_TH'))
    load(strcat(path, experiment.animal_ID, '_TH_PFC'))
    c12 = [c12, gPDC.c12]; 
    c21 = [c21, gPDC.c21]; 
end 
f = gPDC.f; 

% Calculate bounded line values, separated by age 
cnorm = (c21 - c12) ./ (c21 + c12); 
n = 1; 
for idx = 5:12 
    if ismember (idx, age)
        cnormp(:,n) = nanmedian(cnorm(:, age==idx),2); 
        cnorms(:,n) = nanstd(cnorm(:, age==idx), [], 2)./ sqrt(nnz(age==idx)); 
        n = n+1; 
    end 
end 

figure; hold on; 
for idx = 1:size(cnormp,2)
    plot(f, cnormp(:,idx), 'Color',  YlGnBu(round(100/8*idx),:)); 
%     boundedline(PSDstruct.freqs, PowerPlotPFC(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));   
end 
yline(0,'--'); 
ylabel('normalized gPDC (A.U.)'); xlabel('Frequency (Hz)'); xlim([1 50]); set(gca, 'FontSize', 16)
% title('gPDC: PFC→Str', 'FontSize', 14, 'FontName', 'Arial');
% title('gPDC: Str→TH', 'FontSize', 14, 'FontName', 'Arial');
title('gPDC: TH→PFC', 'FontSize', 14, 'FontName', 'Arial');


