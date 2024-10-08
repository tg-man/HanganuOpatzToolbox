%% Opto SDR 

clear
experiments = get_experiment_redux;
experiments = experiments(73:281);
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));  
% experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59);
experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct'))); 
experiments = experiments([experiments.DiI] == 0); 
folderPowRamps = 'Q:\Personal\Tony\Analysis\Results_RampPower\';  
ch_acc = 17:32; 
ch_str = 1:16;
ch_th = 33:48;


%% loop through experiments
for exp_idx = 1:numel(experiments)
    experiment = experiments(exp_idx); 
    disp(['running exp ' num2str(exp_idx) ' / ' num2str(numel(experiments))])
    % initialize PSD variables and load data channel by channel 
    power_pre = []; 
    power_stim = []; 
    
    if strcmp(experiment.sites, '3site') 
        for ch = 1:48 
            load([folderPowRamps experiment.name '\' num2str(ch)])
            power_pre = [power_pre; median(StimPowerRamps.Pre_sup,1)];
            power_stim = [power_stim; median(StimPowerRamps.Half2_sup,1)];
        end
    elseif strcmp(experiment.sites, '2site')
        for ch = 1:32
            load([folderPowRamps experiment.name '\' num2str(ch)])
            power_pre = [power_pre; median(StimPowerRamps.Pre_sup,1)];
            power_stim = [power_stim; median(StimPowerRamps.Half2_sup,1)];
        end
    end 

    % take out bad channels 
    bad_ch = rmmissing([experiment.NoisyCh,experiment.OffCh]);
    power_pre(bad_ch,:) = NaN; 
    power_stim(bad_ch,:) = NaN; 
    
    % compute SDR (acc str) 
    if experiment.target1 == 1 && experiment.target2 == 1
        SDRpre_accstr(exp_idx, :) = getSDR(nanmedian(power_pre(ch_acc,:)), nanmedian(power_pre(ch_str,:)), [], []); 
        SDRstim_accstr(exp_idx, :) = getSDR(nanmedian(power_stim(ch_acc,:)), nanmedian(power_stim(ch_str,:)), [], []); 
    else
        SDRpre_accstr(exp_idx, :) = NaN; 
        SDRstim_accstr(exp_idx, :) = NaN; 
    end 
    
    % compute SDR (acc th) 
    if experiment.target1 == 1 && experiment.target3 == 1
        SDRpre_accth(exp_idx, :) = getSDR(nanmedian(power_pre(ch_acc,:)), nanmedian(power_pre(ch_th,:)), [], []); 
        SDRstim_accth(exp_idx, :) = getSDR(nanmedian(power_stim(ch_acc,:)), nanmedian(power_stim(ch_th,:)), [], []); 
    else 
        SDRpre_accth(exp_idx, :) = NaN; 
        SDRstim_accth(exp_idx, :) = NaN; 
    end 
end

figure; 
SDRpre_accstr_norm = (SDRpre_accstr(:,1) - SDRpre_accstr(:,2))./(SDRpre_accstr(:,1) + SDRpre_accstr(:,2));
SDRstim_accstr_norm = (SDRstim_accstr(:,1) - SDRstim_accstr(:,2))./(SDRstim_accstr(:,1) + SDRstim_accstr(:,2));
SDR_accstr_norm = [SDRpre_accstr_norm, SDRstim_accstr_norm]; 
violins = violinplot(SDR_accstr_norm); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
ylabel('normalized SDR'); xticklabels({'pre','stim'});
set(gca, 'FontSize', 16, 'Fontname', 'Arial'); 
title('SDR: ACC \rightarrow DMS', 'FontWeight', 'Bold')
plot([1.2,1.8], [SDR_accstr_norm(:,1),SDR_accstr_norm(:,2)], 'k')


figure; 
SDRpre_accth_norm = (SDRpre_accth(:,1) - SDRpre_accth(:,2))./(SDRpre_accth(:,1) + SDRpre_accth(:,2));
SDRstim_accth_norm = (SDRstim_accth(:,1) - SDRstim_accth(:,2))./(SDRstim_accth(:,1) + SDRstim_accth(:,2));
SDR_accth_norm = [SDRpre_accth_norm, SDRstim_accth_norm]; 
violins = violinplot(SDR_accth_norm); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
ylabel('normalized SDR'); xticklabels({'pre','stim'});
set(gca, 'FontSize', 16, 'Fontname', 'Arial'); 
title('SDR: ACC \rightarrow MD', 'FontWeight', 'Bold')
plot([1.2,1.8], [SDR_accth_norm(:,1),SDR_accth_norm(:,2)], 'k')

% Code to generate struct for Mattia 
% 
% for exp_idx = 1:size(experiments, 2) 
%     OptoSDRstr(exp_idx).animal_ID = experiments(exp_idx).animal_ID 
%     OptoSDRstr(exp_idx).SDRpre = SDRpre_accstr_norm(exp_idx) 
%     OptoSDRstr(exp_idx).SDRstim = SDRstim_accstr_norm(exp_idx)
%     OptoSDRstr(exp_idx).pair = 'PFC to Str'; 
% end 
% 
% for exp_idx = 1:size(experiments, 2) 
%     OptoSDRth(exp_idx).animal_ID = experiments(exp_idx).animal_ID 
%     OptoSDRth(exp_idx).SDRpre = SDRpre_accth_norm(exp_idx) 
%     OptoSDRth(exp_idx).SDRstim = SDRstim_accth_norm(exp_idx)
%     OptoSDRth(exp_idx).pair = 'PFC to TH'; 
% end 
%  
% 
% OptoSDR = horzcat(OptoSDRstr, OptoSDRth)
% field = 'mycell';
% value = {{'a','b','c'}};
% s = struct(field,value)

[H_str, p_str] = ttest(SDR_accstr_norm(:,1), SDR_accstr_norm(:,2))
[H_th, p_th] = ttest(SDR_accth_norm(:,1), SDR_accth_norm(:,2))

