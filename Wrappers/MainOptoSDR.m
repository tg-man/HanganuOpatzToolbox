%% Opto SDR 

clear
experiments = get_experiment_redux;
experiments = experiments([80:127]);
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
folderPowRamps = 'Q:\Personal\Tony\Analysis\Results_3Probe_RampPower_3s\'; 
ch_acc = 17:32; 
ch_str = 1:16; 
ch_th = 33:48; 

% loop through experiments
for exp_idx = 1:numel(experiments)
    experiment = experiments(exp_idx); 
    disp(['running exp ' num2str(exp_idx) ' / ' num2str(numel(experiments))])
    % initialize PSD variables and load data channel by channel 
    power_pre = []; 
    power_stim = []; 
    for ch = 1:48 
        load([folderPowRamps experiment.name '\' num2str(ch)])
        power_pre = [power_pre; median(StimPowerRamps.Pre_sup,1)];
        power_stim = [power_stim; median(StimPowerRamps.Half2_sup,1)];
    end
    
    % take out bad channels 
    bad_ch = [experiment.NoisyCh,experiment.OffCh];
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
SDRpre_accstr_norm = (SDRpre_accstr(:,1) - SDRpre_accstr(:,2))./(SDRpre_accstr(:,1) + SDRpre_accstr(:,2))
SDRstim_accstr_norm = (SDRstim_accstr(:,1) - SDRstim_accstr(:,2))./(SDRstim_accstr(:,1) + SDRstim_accstr(:,2))
SDR_accstr_norm = [SDRpre_accstr_norm, SDRstim_accstr_norm]; 
violinplot(SDR_accstr_norm); 
ylabel('normalized SDR'); xticklabels({'pre','stim'});
set(gca, 'FontSize', 16, 'Fontname', 'Arial'); 
title('SDR: ACC -> Str', 'FontWeight', 'Bold')
plot([1.3,1.7], [SDR_accstr_norm(:,1),SDR_accstr_norm(:,2)], 'k')


figure; 
SDRpre_accth_norm = (SDRpre_accth(:,1) - SDRpre_accth(:,2))./(SDRpre_accth(:,1) + SDRpre_accth(:,2))
SDRstim_accth_norm = (SDRstim_accth(:,1) - SDRstim_accth(:,2))./(SDRstim_accth(:,1) + SDRstim_accth(:,2))
SDR_accth_norm = [SDRpre_accth_norm, SDRstim_accth_norm]; 
violinplot(SDR_accth_norm); 
ylabel('normalized SDR'); xticklabels({'pre','stim'});
set(gca, 'FontSize', 16, 'Fontname', 'Arial'); 
title('SDR: ACC -> TH', 'FontWeight', 'Bold')
plot([1.3,1.7], [SDR_accth_norm(:,1),SDR_accth_norm(:,2)], 'k')

