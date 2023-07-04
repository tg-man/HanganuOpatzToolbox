%% Main Opto gPDC 

clear
experiments = get_experiment_redux;
experiments = experiments([80:157]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 87);
save_data = 1;
repeatCalc = 1;
folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_StimProp\';
resultaccstr = 'Q:\Personal\Tony\Analysis\Results_3Probe_RampgPDC\ACCStr\';
resultaccth = 'Q:\Personal\Tony\Analysis\Results_3Probe_RampgPDC\ACCTH\';

% loading and filtering variables
fs = 32000; % sampling rate from data
downsampling_factor = 32; % downsample for LFP analysis
fs_LFP = fs / downsampling_factor;
high_cut = fs_LFP/2; % nyquist frequency here! 
ExtractMode = 1; % extract from neuralynx into matlab
ch2load = 1:48; % select channels to load
cores = 6; 

%% running section 

for exp_idx = 1 : size(experiments, 2) 
    tic
    experiment = experiments(exp_idx); 
        
    disp(['Loading signal ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))]);
    parfor (channel = ch2load, cores)
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs, [1 high_cut]); % origianlly 0.1
        LFP(channel, :) = signal(1 : downsampling_factor : end);
    end
    bad_ch = [experiment.NoisyCh,experiment.OffCh];
    bad_ch = bad_ch(ismember(bad_ch, ch2load));
    LFP(bad_ch, :) = NaN; % Do the same here for noisy channels
    
    % take median of all channels
    LFP_PFC = nanmedian(LFP(17:32,:));
    LFP_Str = nanmedian(LFP(1:16,:));
    LFP_TH = nanmedian(LFP(33:48,:));
    clear LFP
    
    % check targetting and actual gPDC computation
    disp(['computing ramp gPDC ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))]);
    if experiment.target1 == 1 && experiment.target2 == 1 
        getRampGPDC(experiment, LFP_PFC, LFP_Str, fs_LFP, high_cut, folder4stim,  repeatCalc, save_data, resultaccstr)
    end 
    if experiment.target1 ==1 && experiment.target3 == 1
        getRampGPDC(experiment, LFP_PFC, LFP_TH, fs_LFP, high_cut, folder4stim,  repeatCalc, save_data, resultaccth)
    end 
    toc
end 

%% plotting section 

clear
experiments = get_experiment_redux;
experiments = experiments([80:157]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 87);
save_data = 1;
repeatCalc = 1;
resultaccstr = 'Q:\Personal\Tony\Analysis\Results_3Probe_RampgPDC\ACCStr\';
resultaccth = 'Q:\Personal\Tony\Analysis\Results_3Probe_RampgPDC\ACCTH\';


for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 
    
    if experiment.target1 == 1 && experiment.target2 == 1 
        load([resultaccstr experiment.name '_gPDC_ramp.mat']); 
        prenorm_accstr(:, exp_idx) = nanmedian((gPDC_ramp.pre21 - gPDC_ramp.pre12) ./ (gPDC_ramp.pre12 + gPDC_ramp.pre21), 2); 
        stimnorm_accstr(:, exp_idx) = nanmedian((gPDC_ramp.stim21 - gPDC_ramp.stim12) ./ (gPDC_ramp.stim12 + gPDC_ramp.stim21),2); 
    else 
        prenorm_accstr(:, exp_idx) = NaN; 
        stimnorm_accstr(:, exp_idx) = NaN;    
    end 
    
    if experiment.target1 ==1 && experiment.target3 == 1
        load([resultaccth experiment.name '_gPDC_ramp.mat']); 
        prenorm_accth(:, exp_idx) = nanmedian((gPDC_ramp.pre21 - gPDC_ramp.pre12) ./ (gPDC_ramp.pre12 + gPDC_ramp.pre21), 2); 
        stimnorm_accth(:, exp_idx) = nanmedian((gPDC_ramp.stim21 - gPDC_ramp.stim12) ./ (gPDC_ramp.stim12 + gPDC_ramp.stim21),2); 
     else 
        prenorm_accth(:, exp_idx) = NaN; 
        stimnorm_accth(:, exp_idx) = NaN;           
    end 
end 

figure; 
boundedline(gPDC_ramp.f, nanmedian(prenorm_accstr,2), nanmedian(prenorm_accstr,2)./sqrt(sum(~isnan(prenorm_accstr(1,:))))); hold on;
boundedline(gPDC_ramp.f, nanmedian(stimnorm_accstr,2), nanmedian(stimnorm_accstr,2)./sqrt(sum(~isnan(stimnorm_accstr(1,:)))), 'r');
xlim([2 49]); yline(0, ':'); 
legend('', 'pre', '', 'stim', ''); 
xlabel('frequency (Hz)'); ylabel('normalized gPDC'); 
title('ramp gPDC: PFC → Str') 

figure; 
boundedline(gPDC_ramp.f, nanmedian(prenorm_accth,2), nanmedian(prenorm_accth,2)./sqrt(sum(~isnan(prenorm_accth(1,:))))); hold on;
boundedline(gPDC_ramp.f, nanmedian(stimnorm_accth,2), nanmedian(stimnorm_accth,2)./sqrt(sum(~isnan(stimnorm_accth(1,:)))), 'r');
xlim([2 49]); yline(0, ':'); 
legend('', 'pre', '', 'stim', ''); 
xlabel('frequency (Hz)'); ylabel('normalized gPDC'); 
title('ramp gPDC: PFC → TH') 























