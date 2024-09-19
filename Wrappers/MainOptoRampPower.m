
clear
experiments = get_experiment_redux;
experiments = experiments([282:420]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
% experiments = experiments(strcmp(extractfield(experiments, 'sites'), '2site'));
% experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59);
% experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct')));
save_data = 1;
repeatCalc = 0;
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\';
folderPowRamps = 'Q:\Personal\Tony\Analysis\Results_RampPower\'; % getRampPower params needs to be adjusted accordingly! 
BrainAreas = {'ACC', 'Str', 'TH'}; %{'ACC','PL','Str','TH'};
% stimArea = 'ACCsup';
% experiments = experiments(strcmp(extractfield(experiments, 'square'), stimArea)); 
% experiments = experiments(strcmp(extractfield(experiments, 'sites'), '3site')); 
CSCs = 1:48; 
cores = 4; 


% compute/plot ramp power stuff
getStimProperties(experiments, save_data, repeatCalc, folder4stim)

for idx = 1 : numel(experiments)
    experiment = experiments(idx); 
    disp(['running experiment number ' num2str(idx) ' out of ' num2str(size(experiments, 2))])
    parfor (CSC = CSCs, cores) 
        getRampPower(experiment, CSC, save_data, repeatCalc, folder4stim, folderPowRamps);
    end 
end

% % bad channels were taking out during plotting 
% plotRampPower(experiments, stimArea, BrainAreas, folderPowRamps)

%plotRampSignal(experiment, CSC, save_data, repeatCalc, folder4stim, folderPowRamps); 

%% generate some struct 
% 
% 
% [Spectrumpre_str, SpectrumStim_str, ~] = plotRampPower(experiments, stimArea, {'Str'}, folderPowRamps);
% [Spectrumpre_th, SpectrumStim_th, freq] = plotRampPower(experiments, stimArea, {'TH'}, folderPowRamps);
% 
% MI_Str_RR = getMI(sum(SpectrumStim_str(:, freq > 2 & freq < 4), 2), sum(Spectrumpre_str(:, freq > 2 & freq < 4), 2), 0); 
% MI_Str_theta = getMI(sum(SpectrumStim_str(:, freq > 4 & freq < 12), 2), sum(Spectrumpre_str(:, freq > 4 & freq < 12), 2), 0);
% MI_Str_beta = getMI(sum(SpectrumStim_str(:, freq > 12 & freq < 30), 2), sum(Spectrumpre_str(:, freq > 12 & freq < 30), 2), 0);
% MI_Str_gamma = getMI(sum(SpectrumStim_str(:, freq > 30 & freq < 50), 2), sum(Spectrumpre_str(:, freq > 30 & freq < 50), 2), 0);
% 
% for exp_idx = 1:size(experiments, 2) 
%     RampPowerMIstr(exp_idx).animal_ID = experiments(exp_idx).animal_ID 
%     RampPowerMIstr(exp_idx).MI_RR = MI_Str_RR(exp_idx); 
%     RampPowerMIstr(exp_idx).MI_theta = MI_Str_theta(exp_idx); 
%     RampPowerMIstr(exp_idx).MI_beta = MI_Str_beta(exp_idx); 
%     RampPowerMIstr(exp_idx).MI_gamma = MI_Str_gamma(exp_idx); 
%     RampPowerMIstr(exp_idx).area = 'Str'; 
% end 
% 
% MI_th_RR = getMI(sum(SpectrumStim_th(:, freq > 2 & freq < 4), 2), sum(Spectrumpre_th(:, freq > 2 & freq < 4), 2), 0); 
% MI_th_theta = getMI(sum(SpectrumStim_th(:, freq > 4 & freq < 12), 2), sum(Spectrumpre_th(:, freq > 4 & freq < 12), 2), 0);
% MI_th_beta = getMI(sum(SpectrumStim_th(:, freq > 12 & freq < 30), 2), sum(Spectrumpre_th(:, freq > 12 & freq < 30), 2), 0);
% MI_th_gamma = getMI(sum(SpectrumStim_th(:, freq > 30 & freq < 50), 2), sum(Spectrumpre_th(:, freq > 30 & freq < 50), 2), 0);
% 
% for exp_idx = 1:size(experiments, 2) 
%     RampPowerMIth(exp_idx).animal_ID = experiments(exp_idx).animal_ID 
%     RampPowerMIth(exp_idx).MI_RR = MI_th_RR(exp_idx); 
%     RampPowerMIth(exp_idx).MI_theta = MI_th_theta(exp_idx); 
%     RampPowerMIth(exp_idx).MI_beta = MI_th_beta(exp_idx); 
%     RampPowerMIth(exp_idx).MI_gamma = MI_th_gamma(exp_idx); 
%     RampPowerMIth(exp_idx).area = 'TH'; 
% end 
% 
% RampPowerMI = [RampPowerMIstr, RampPowerMIth]
