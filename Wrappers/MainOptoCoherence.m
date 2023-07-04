%% Coherence for opto data 

clear
experiments = get_experiment_redux;
experiments = experiments([80:145]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
ramp_length = 3; % in seconds
save_data = 1;
repeatCalc = 0; 
coh4accstr = 'Q:\Personal\Tony\Analysis\Results_3Probe_CohOpto\ACCStr\'; 
coh4accth = 'Q:\Personal\Tony\Analysis\Results_3Probe_CohOpto\ACCTH\';
folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_StimProp\';
freq_filt = [2 500];
ExtractMode = 1;
downsampling_factor = 32; % to convert signal to miliseconds
cores = 6; 
fs = 1000; % final frame rate in Hz for all coherence calculations; 
shift = 1 * fs; % in miliseconds, the time shift when selecting stim window compared to the actual ramp time 

% colormap
cmap = cbrewer('div', 'RdBu', 100);

% Coherence parameters 
params.fs = fs; 
params.win_length = 1; 
params.overlap = params.win_length / 2; 
params.nfft = 2^13;; 


%% computing section 

getStimProperties(experiments, save_data, repeatCalc, folder4stim)
% loop throught experiments
for exp_idx = 1 : numel(experiments)
    experiment = experiments(exp_idx);
    
    % load signal and set all bad channel to NaN 
    disp(['loading signal exp ' num2str(exp_idx)])
    parfor (channel = 1 : 48, cores)
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        [~, signal, fs_load] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs_load, freq_filt);
        LFP(channel, :) = signal(1 : downsampling_factor : end); % set to 1000 Hz so that everything is in milisecons 
    end 
    bad_ch = [experiment.NoisyCh,experiment.OffCh];
    bad_ch = bad_ch(ismember(bad_ch, 1:48));
    LFP(bad_ch, :) = NaN;
    
    LFP_acc = nanmedian(LFP(17:32,:)); 
    LFP_str = nanmedian(LFP(1:16,:)); 
    LFP_th = nanmedian(LFP(33:48,:)); 
    clear LFP 
    
    % select only proper ramp stim props
    load([folder4stim experiment.name, '_StimulationProperties_raw.mat']);
    StimulationProperties_raw = StimulationProperties_raw(strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp'),:);
    StimulationProperties_raw = StimulationProperties_raw(round(cell2mat(StimulationProperties_raw(:, 5))) == ramp_length,:);
    % stims are in fs = 3.2k
    % generate integar time stamps and + shift to shift the timewindow by 1s back
    stim = round([cell2mat(StimulationProperties_raw(:,1))/3.2 + shift, cell2mat(StimulationProperties_raw(:,2))/3.2 + shift]); 
    pre = round([cell2mat(StimulationProperties_raw(:,1))/3.2 - 3*fs, cell2mat(StimulationProperties_raw(:,1))/3.2]); 
    
    disp('computing coherence...')
    if experiment.target1 == 1 && experiment.target2 ==1
        getRampCoherence(experiment, LFP_acc, LFP_str, pre, stim, params, coh4accstr, repeatCalc, save_data);
    end 
    
    if experiment.target1 == 1 && experiment.target3 ==1
        getRampCoherence(experiment, LFP_acc, LFP_th, pre, stim, params, coh4accth, repeatCalc, save_data); 
    end      
end 

disp('Done computing!')

%% plotting section (Acc Str) 

clear
experiments = get_experiment_redux;
experiments = experiments([80:145]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
coh4accstr = 'Q:\Personal\Tony\Analysis\Results_3Probe_CohOpto\ACCStr\'; 
coh4accth = 'Q:\Personal\Tony\Analysis\Results_3Probe_CohOpto\ACCTH\';
exp = (extractfield(experiments, 'IUEconstruct') == 59);
ctrl = (extractfield(experiments, 'IUEconstruct') == 87);
% colormap
cmap = cbrewer('qual', 'Set1', 9);

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 
    
    % load acc str opto coherence struct
    load([coh4accstr experiment.name]); 
    
    % extract data
    coh4plot(exp_idx,:,1) = nanmedian(StimRampCoh.Coherency_pre, 2); % pre data
    coh4plot(exp_idx,:,2) = nanmedian(StimRampCoh.Coherency_stim, 2); % stim data
    relcoh(exp_idx,:) = getMI(coh4plot(exp_idx,:,2), coh4plot(exp_idx,:,1), 0); 
    
end 

freqs = StimRampCoh.freqs; 
figure; 
boundedline(freqs, nanmedian(relcoh(exp,:)), nanstd(relcoh(exp,:))./sqrt(sum(exp)), 'cmap', cmap(1,:)); hold on; 
boundedline(freqs, nanmedian(relcoh(ctrl,:)), nanstd(relcoh(ctrl,:))./sqrt(sum(ctrl)), 'cmap', cmap(3,:)); hold on; 
set(gca,'TickDir','out', 'FontSize',12, 'FontName', 'Arial'); 
xlabel('Frequency (Hz)'); ylabel('MI');
title('Str to ACC stim', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Arial'); 
yline(0); xlim([2 49]); ylim([-0.3 0.3]);
legend('', 'exp', '', 'ctrl', '');


freqs = StimRampCoh.freqs; 
figure; 
boundedline(freqs, nanmedian(coh4plot(:,:,1)), nanstd(coh4plot(:,:,1))./sqrt(exp_idx), 'cmap', cmap(9, :)); hold on; 
boundedline(freqs, nanmedian(coh4plot(exp,:,2)), nanstd(coh4plot(:,:,2))./sqrt(exp_idx), 'cmap', cmap(1, :));
boundedline(freqs, nanmedian(coh4plot(ctrl,:,2)), nanstd(coh4plot(:,:,2))./sqrt(exp_idx), 'cmap', cmap(3, :));
xlim([2 49]); ylim([0.1 0.35])
set(gca,'TickDir','out', 'FontSize',12, 'FontName', 'Arial'); 
xlabel('Frequency (Hz)'); ylabel('Imag Coh');
title('Str to ACC stim', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Arial'); 
legend('','pre','','stim', '', 'ctrl');


%% plotting section (Acc th) 


clear
experiments = get_experiment_redux;
experiments = experiments([80:145]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(extractfield(experiments, 'target3') == 1);
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
coh4accstr = 'Q:\Personal\Tony\Analysis\Results_3Probe_CohOpto\ACCStr\'; 
coh4accth = 'Q:\Personal\Tony\Analysis\Results_3Probe_CohOpto\ACCTH\';
exp = (extractfield(experiments, 'IUEconstruct') == 59);
ctrl = (extractfield(experiments, 'IUEconstruct') == 87); 
% colormap
cmap = cbrewer('qual', 'Set1', 9);


for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 
    
    % load acc str opto coherence struct
    load([coh4accth experiment.name]); 
    
    % extract data
    coh4plot(exp_idx,:,1) = nanmedian(StimRampCoh.Coherency_pre, 2); % pre data    
    coh4plot(exp_idx,:,2) = nanmedian(StimRampCoh.Coherency_stim, 2); % stim data 
    relcoh(exp_idx,:) = getMI(coh4plot(exp_idx,:,2), coh4plot(exp_idx,:,1), 0); 
end 

freqs = StimRampCoh.freqs; 
figure; 
boundedline(freqs, nanmedian(relcoh(exp,:)), nanstd(relcoh(exp,:))./sqrt(sum(exp)), 'cmap', cmap(1,:)); hold on; 
boundedline(freqs, nanmedian(relcoh(ctrl,:)), nanstd(relcoh(ctrl,:))./sqrt(sum(ctrl)), 'cmap', cmap(3,:)); hold on; 
set(gca,'TickDir','out', 'FontSize',12, 'FontName', 'Arial'); 
xlabel('Frequency (Hz)'); ylabel('MI');
title('TH to ACC stim', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Arial'); 
yline(0); xlim([2 49]); ylim([-0.3 0.3]);
legend('', 'exp', '', 'ctrl', '');


freqs = StimRampCoh.freqs; 
figure; 
boundedline(freqs, nanmedian(coh4plot(:,:,1)), nanstd(coh4plot(:,:,1))./sqrt(exp_idx), 'cmap', cmap(9, :)); hold on; 
boundedline(freqs, nanmedian(coh4plot(exp,:,2)), nanstd(coh4plot(:,:,2))./sqrt(exp_idx), 'cmap', cmap(1, :));
boundedline(freqs, nanmedian(coh4plot(ctrl,:,2)), nanstd(coh4plot(:,:,2))./sqrt(exp_idx), 'cmap', cmap(3, :));
xlim([2 49]); ylim([0.1 0.5])
set(gca,'TickDir','out', 'FontSize',12, 'FontName', 'Arial'); 
xlabel('Frequency (Hz)'); ylabel('Imag Coh');
title('TH to ACC stim', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Arial'); 
legend('','pre','','stim','','ctrl');














