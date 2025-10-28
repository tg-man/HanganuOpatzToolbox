%% Opto SDR 

clear
% filter experiments 
experiments = get_experiment_redux;
for i = 1 : size(experiments, 2)
    experiment = experiments(i); 
    if length(experiment.IUEconstruct) == 1
        keep(i) = 1; 
    else
        keep(i) = 0; 
    end 
end 
experiments = experiments(logical(keep)); %[300 301 324:426]
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments([experiments.DiI] == 0); 

% select stim location: ACC or Str 
stimarea = 'ACC'; 
% stimarea = 'Str'; 
experiments = experiments(contains({experiments.ramp}, stimarea)); 

% select condition: injection or control 
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 13);
% experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct')));

folderPowRamps = 'Q:\Personal\Tony\Analysis\Results_RampPower\';  
folder2save = 'Q:\Personal\Tony\Analysis\Results_RampSDR\';

freq_bin = [4 45]; 

ch_acc = 17:32; 
ch_str = 1:16;
% ch_th = 33:48;

% unique animal lists 
animals = unique({experiments.animal_ID}); 

% initialize tables 
T = []; 
T_mouse = []; 

% loop through each mouse 
for mouse_idx = 1 : numel(animals) 

    disp(['computing mouse ' num2str(mouse_idx) ' / ' num2str(numel(animals))])
    mouse = animals(mouse_idx); 

    % get experiments of this mouse 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse)); 

    % loop through experiments to load ramp powers 
    power_pre = []; 
    power_stim = []; 
    % loop 
    for exp_idx = 1 : numel(exp4mouse) 
        experiment = exp4mouse(exp_idx);
        % initialize PSD variables and load data channel by channel 
        for ch = 1 : 48
            load([folderPowRamps experiment.name '\' num2str(ch)])
            temp_pre(ch, :, :) = StimPowerRamps.Pre;
            temp_stim(ch, :, :) = StimPowerRamps.Half2;
            freqs = StimPowerRamps.freq; 
            clearvars StimPowerRamps 
        end 
        power_pre = [power_pre, temp_pre];
        power_stim = [power_stim, temp_stim];
        clearvars temp_pre temp_stim
    end 
    % take out bad channels 
    bad_ch = rmmissing([experiment.NoisyCh,experiment.OffCh]);
    power_pre(bad_ch, :, :) = NaN; 
    power_stim(bad_ch, :,:) = NaN; 

    % compute SDR ramp by ramp, then populate overall table and animal-averageged table 
    for ramp = 1 : size(power_pre, 2)
        SDRpre(ramp, :) = getSDR(squeeze(nanmedian(power_pre(ch_acc, ramp, :), 1)), squeeze(nanmedian(power_pre(ch_str, ramp, :), 1)), freqs, freq_bin); 
        SDRstim(ramp, :) = getSDR(squeeze(nanmedian(power_stim(ch_acc, ramp, :), 1)), squeeze(nanmedian(power_stim(ch_str, ramp, :), 1)), freqs, freq_bin); 
    end 
    % normalize 
    SDRpre_norm = (SDRpre(:, 1) - SDRpre(:, 2)) ./ (SDRpre(:, 1) + SDRpre(:, 2)); 
    SDRstim_norm = (SDRstim(:, 1) - SDRstim(:, 2)) ./ (SDRstim(:, 1) + SDRstim(:, 2)); 
    % put into table 
    T = [T; table(repmat(mouse, [ramp 1]), SDRpre_norm, SDRstim_norm, 'VariableNames', {'mouse', 'SDRpre', 'SDRstim'})]; 
    T_mouse = [T_mouse; table(mouse, nanmedian(SDRpre_norm), nanmedian(SDRstim_norm), 'VariableNames', {'mouse', 'SDRpre', 'SDRstim'})]; 

    clearvars SDRpre SDRstim SDRpre_norm SDRstim_norm
end 

figure; hold on 
violins = violinplot(T_mouse{:, {'SDRpre', 'SDRstim'}}); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
ylabel('normalized SDR'); xticklabels({'pre','stim'});
set(gca, 'FontSize', 16, 'Fontname', 'Arial', 'Linewidth', 2, 'TickDir', 'out'); 
title('ACC \rightarrow DMS', 'FontWeight', 'Bold')
plot([1.2,1.8], [T_mouse{:, "SDRpre"}, T_mouse{:, "SDRstim"}], 'k', 'Linewidth', 1.5)

[H_str, p_str] = signrank(T_mouse{:, "SDRpre"}, T_mouse{:, "SDRstim"})


T.opsin = repmat(experiment.IUEconstruct, [size(T, 1) 1]);
T.stimarea = repmat(stimarea, [size(T, 1) 1]);

Tpre = [T(:, {'mouse', 'SDRpre', 'opsin', 'stimarea'}) table(repmat({'pre'}, [size(T, 1) 1]), 'VariableNames', {'condition'})]; 
Tpre = renamevars(Tpre, "SDRpre", "SDR");
Tstim = [T(:, {'mouse', 'SDRstim', 'opsin', 'stimarea'}) table(repmat({'stim'}, [size(T, 1) 1]), 'VariableNames', {'condition'})];
Tstim = renamevars(Tstim, "SDRstim", "SDR");

T2save = [Tpre; Tstim]; 

writetable(T2save, [folder2save 'RampSDR_' num2str(experiment.IUEconstruct) '_' experiment.ramp(1:3) '.csv']); 

% figure; hold on 
% violins = violinplot([T_mouse{:, {'SDRpre', 'SDRstim'}}; [NaN NaN]]); 
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% ylabel('normalized SDR'); xticklabels({'pre','stim'});
% set(gca, 'FontSize', 16, 'Fontname', 'Arial', 'Linewidth', 2, 'TickDir', 'out'); 
% title('SDR: ACC \rightarrow DMS', 'FontWeight', 'Bold')
% plot([1.2,1.8], [T_mouse{:, "SDRpre"}, T_mouse{:, "SDRstim"}], 'k', 'Linewidth', 1.5)
% xlim([0.5 2.5])
% ylim([-0.05 0.2])

%% another version: 
% % instead of computing SDR ramp by ramp 
% % do so on ramp-averaged power spectra 
% 
% clear
% % filter experiments 
% experiments = get_experiment_redux;
% for i = 1 : size(experiments, 2)
%     experiment = experiments(i); 
%     if length(experiment.IUEconstruct) == 1
%         keep(i) = 1; 
%     else
%         keep(i) = 0; 
%     end 
% end 
% experiments = experiments(logical(keep)); %[300 301 324:426]
% experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
% experiments = experiments([experiments.DiI] == 0); 
% 
% % select stim location: ACC or Str 
% experiments = experiments(contains({experiments.ramp}, 'ACC')); 
% % experiments = experiments(contains({experiments.ramp}, 'Str')); 
% 
% % select condition: injection or control 
% % experiments = experiments(extractfield(experiments, 'IUEconstruct') == 13);
% experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct')));
% 
% folderPowRamps = 'Q:\Personal\Tony\Analysis\Results_RampPower\';  
% 
% freq_bin = [4 50]; 
% 
% ch_acc = 17:32; 
% ch_str = 1:16;
% % ch_th = 33:48;
% 
% % loop through experiments
% animals = unique({experiments.animal_ID}); 
% 
% % initialize tables 
% T_mouse = []; 
% 
% % loop through each mouse 
% for mouse_idx = 1 : numel(animals) 
% 
%     disp(['computing mouse ' num2str(mouse_idx) ' / ' num2str(numel(animals))])
%     mouse = animals(mouse_idx); 
% 
%     % get experiments of this mouse 
%     exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse)); 
% 
%     % loop through experiments to load ramp powers 
%     power_pre = []; 
%     power_stim = []; 
%     % loop 
%     for exp_idx = 1 : numel(exp4mouse) 
%         experiment = exp4mouse(exp_idx);
%         % initialize PSD variables and load data channel by channel 
%         for ch = 1 : 48
%             load([folderPowRamps experiment.name '\' num2str(ch)])
%             temp_pre(ch, :, :) = StimPowerRamps.Pre_sup;
%             temp_stim(ch, :, :) = StimPowerRamps.Half2_sup;
%             freqs = StimPowerRamps.freq; 
%             clearvars StimPowerRamps 
%         end 
%         power_pre = [power_pre, temp_pre];
%         power_stim = [power_stim, temp_stim];
%         clearvars temp_pre temp_stim
%     end 
%     % take out bad channels 
%     bad_ch = rmmissing([experiment.NoisyCh,experiment.OffCh]);
%     power_pre(bad_ch, :, :) = NaN; 
%     power_stim(bad_ch, :,:) = NaN; 
%     % average across ramps 
%     power_pre = squeeze(nanmedian(power_pre, 2)); 
%     power_stim = squeeze(nanmedian(power_stim, 2)); 
% 
%     % compute SDR ramp by ramp, then populate overall table and animal-averageged table 
%     SDRpre = getSDR(nanmedian(power_pre(ch_acc, :), 1), nanmedian(power_pre(ch_str, :), 1), freqs, freq_bin); 
%     SDRstim = getSDR(nanmedian(power_stim(ch_acc, :), 1), nanmedian(power_stim(ch_str, :), 1), freqs, freq_bin); 
% 
%     % normalize 
%     SDRpre_norm = (SDRpre(:, 1) - SDRpre(:, 2)) ./ (SDRpre(:, 1) + SDRpre(:, 2)); 
%     SDRstim_norm = (SDRstim(:, 1) - SDRstim(:, 2)) ./ (SDRstim(:, 1) + SDRstim(:, 2)); 
%     % put into table 
%     T_mouse = [T_mouse; table(mouse, nanmedian(SDRpre_norm), nanmedian(SDRstim_norm), 'VariableNames', {'mouse', 'SDRpre', 'SDRstim'})]; 
% 
%     clearvars SDRpre SDRstim SDRpre_norm SDRstim_norm
% end 
% 
% figure; 
% violins = violinplot(T_mouse{:, {'SDRpre', 'SDRstim'}}); 
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% ylabel('normalized SDR'); xticklabels({'pre','stim'});
% set(gca, 'FontSize', 16, 'Fontname', 'Arial', 'Linewidth', 2, 'TickDir', 'out'); 
% title('SDR: ACC \rightarrow DMS', 'FontWeight', 'Bold')
% plot([1.2,1.8], [T_mouse{:, "SDRpre"}, T_mouse{:, "SDRstim"}], 'k', 'Linewidth', 1.5)
% 
% [H_str, p_str] = signrank(T_mouse{:, "SDRpre"}, T_mouse{:, "SDRstim"})



%% old deprecated code 

% for exp_idx = 1:numel(experiments)
%     experiment = experiments(exp_idx); 
%     disp(['running exp ' num2str(exp_idx) ' / ' num2str(numel(experiments))])
%     % initialize PSD variables and load data channel by channel 
%     power_pre = []; 
%     power_stim = []; 
%     
%     if strcmp(experiment.sites, '3site') 
%         for ch = 1:48 
%             load([folderPowRamps experiment.name '\' num2str(ch)])
%             power_pre = [power_pre; median(StimPowerRamps.Pre_sup,1)];
%             power_stim = [power_stim; median(StimPowerRamps.Half2_sup,1)];
%         end
%     elseif strcmp(experiment.sites, '2site')
%         for ch = 1:32
%             load([folderPowRamps experiment.name '\' num2str(ch)])
%             power_pre = [power_pre; median(StimPowerRamps.Pre_sup,1)];
%             power_stim = [power_stim; median(StimPowerRamps.Half2_sup,1)];
%         end
%     end 
% 
%     % take out bad channels 
%     bad_ch = rmmissing([experiment.NoisyCh,experiment.OffCh]);
%     power_pre(bad_ch,:) = NaN; 
%     power_stim(bad_ch,:) = NaN; 
%     
%     % compute SDR (acc str) 
%     if experiment.target1 == 1 && experiment.target2 == 1
%         SDRpre_accstr(exp_idx, :) = getSDR(nanmedian(power_pre(ch_acc,:)), nanmedian(power_pre(ch_str,:)), [], []); 
%         SDRstim_accstr(exp_idx, :) = getSDR(nanmedian(power_stim(ch_acc,:)), nanmedian(power_stim(ch_str,:)), [], []); 
%     else
%         SDRpre_accstr(exp_idx, :) = NaN; 
%         SDRstim_accstr(exp_idx, :) = NaN; 
%     end 
%     
%     % compute SDR (acc th) 
%     if experiment.target1 == 1 && experiment.target3 == 1
%         SDRpre_accth(exp_idx, :) = getSDR(nanmedian(power_pre(ch_acc,:)), nanmedian(power_pre(ch_th,:)), [], []); 
%         SDRstim_accth(exp_idx, :) = getSDR(nanmedian(power_stim(ch_acc,:)), nanmedian(power_stim(ch_th,:)), [], []); 
%     else 
%         SDRpre_accth(exp_idx, :) = NaN; 
%         SDRstim_accth(exp_idx, :) = NaN; 
%     end 
% end
% 
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
% 
% figure; 
% SDRpre_accth_norm = (SDRpre_accth(:,1) - SDRpre_accth(:,2))./(SDRpre_accth(:,1) + SDRpre_accth(:,2));
% SDRstim_accth_norm = (SDRstim_accth(:,1) - SDRstim_accth(:,2))./(SDRstim_accth(:,1) + SDRstim_accth(:,2));
% SDR_accth_norm = [SDRpre_accth_norm, SDRstim_accth_norm]; 
% violins = violinplot(SDR_accth_norm); 
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% ylabel('normalized SDR'); xticklabels({'pre','stim'});
% set(gca, 'FontSize', 16, 'Fontname', 'Arial', 'Linewidth', 2, 'TickDir', 'out'); 
% title('SDR: ACC \rightarrow MD', 'FontWeight', 'Bold')
% plot([1.2,1.8], [SDR_accth_norm(:,1),SDR_accth_norm(:,2)], 'k', 'Linewidth', 1.5)
% 
% 
% [H_str, p_str] = signrank(SDR_accstr_norm(:,1), SDR_accstr_norm(:,2))
% [H_th, p_th] = signrank(SDR_accth_norm(:,1), SDR_accth_norm(:,2))

