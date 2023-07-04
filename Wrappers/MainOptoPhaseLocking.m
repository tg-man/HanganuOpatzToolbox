%% calculate phase locking for opto experiments 

clear; 
experiments = get_experiment_redux;
experiments = experiments([80:138]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
areas ={'Str', 'TH3'}; 
freqs = [4 12 30 70]; 
downsampling_factor = 32; % signal to milisecond from fs of 32000 hz 
cores = 4; 
ExtractMode = 1; 
ch2load = 19; 
save_data = 1; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_3Probe_PLVramp\'; 
folder4matrix = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesRamp_shift\'; 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_StimProp\';

%% the acutal calculation 

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); % select single experiment
    
    % load all PFC LFPs here 
    disp(['signal loading ' num2str(exp_idx)])
      
    file_to_load = [experiment.path, experiment.name, '\CSC', num2str(ch2load), '.ncs'];
    [~, signal, fs_load] = load_nlx_Modes(file_to_load, ExtractMode, []);
%     LFP(channel - 16, :) = signal(1 : downsampling_factor : end); % set to 1000 Hz so that everything is in milisecons 
%     bad_ch = [experiment.NoisyCh,experiment.OffCh];
%     bad_ch = bad_ch(ismember(bad_ch, ch2load));
%     LFP(bad_ch - 16, :) = NaN; % Do the same here for noisy channels
    LFP = signal(1 : downsampling_factor : end);
%     %take average of PFC LFP 
%     LFP = nanmedian(LFP, 1);
%     
    % loop through spikes of each area 
    for area_idx = 1 : size(areas,2)        
        area = char(areas(area_idx)); 
        disp(['computing PLV & PPC for ' area])
        
        % check if target is on 
        if (strcmp(area, 'TH3') && experiment.target3 == 1) || (strcmp(area, 'Str') && experiment.target2 == 1)    
            % load spike matrix 
            load([folder4matrix area '\' experiment.name '.mat'])
            spike_matrix = SUAdata_ramp.ramp_spike_matrix; 

            % load stim properties 
            load([folder4stim experiment.name, '_StimulationProperties_raw.mat']);
            StimulationProperties_raw = StimulationProperties_raw(strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp'),:);
            stim_end = round(cell2mat(StimulationProperties_raw(:, 2)) ./ 3.2); % dvided by 3.2 to set to ms  
            stim_start = round(cell2mat(StimulationProperties_raw(:, 1)) ./ 3.2); % dvided by 3.2 to set to ms  

            % initialize variable 
            PLV = NaN(length(freqs) - 1, size(spike_matrix, 1), size(spike_matrix, 2), 10000); 
            PPC_pre = NaN(length(freqs) - 1, size(spike_matrix, 2)); 
            PPC_stim = NaN(length(freqs) - 1, size(spike_matrix, 2)); 

            % loop over frequency bands, ramps, and units to calculate PLV, in that order 
            for freq_idx = 1 : length(freqs) - 1
                freqband = freqs(freq_idx : freq_idx +1); % select freq band for this iteration
                LFPfilt = ZeroPhaseFilter(LFP, 1000, freqband); % freq filter LFP 
                for ramp = 1 : size(spike_matrix, 1)
                    LFPramp = LFPfilt(stim_end(ramp) - 5999: stim_end(ramp) + 4000);  
                     for unit = 1 : size(spike_matrix, 2)
                         spikeIndx = find(squeeze(spike_matrix(ramp, unit, :))); 
                         phase = angle(hilbert(LFPramp)); % basically a getPhaseLocking function but actually working
                         PLV(freq_idx, ramp, unit, spikeIndx) = phase(spikeIndx);                      
                     end 
                end 
                
                % select PLV for pre vs. stim period 
                PLV_pre = squeeze(PLV(freq_idx, :, :, 1:3000)); 
                PLV_stim = squeeze(PLV(freq_idx, :, :, 4001:7000)); 
                
                % permute dimension and reshape so that one unit have only one long phase vector from all ramp stims 
                PLV_pre = permute(PLV_pre, [3 1 2]); 
                PLV_stim = permute(PLV_stim, [3 1 2]);               
                PLV_pre = reshape(PLV_pre, 90000, unit, []); 
                PLV_stim = reshape(PLV_stim, 90000, unit, []); 
                
                % compute PPC unit by unit
                for unit = 1 : size(spike_matrix, 2) 
                    PPC_pre(freq_idx, unit) = computePPC(PLV_pre(:, unit)'); 
                    PPC_stim(freq_idx, unit) = computePPC(PLV_stim(:, unit)'); 
                end 
            end 

            % put everything in a structure 
            PhaseStuff.PLV = PLV; 
            PhaseStuff.PPC_pre = PPC_pre; 
            PhaseStuff.PPC_stim = PPC_stim; 
            PhaseStuff.freqs = freqs;
            PhaseStuff.Notes = 'dimensions: freq_idx, ramp, unit, phase@spike time'; 

            % save data 
            if save_data == 1 
                if ~exist([folder2save area], 'dir')
                    mkdir([folder2save area])
                else 
                    save([folder2save area '\' experiment.name], 'PhaseStuff') 
                end
            elseif ~save_data == 1
                disp(['Data not saved!'])
            end
                     
        end 
        clear PLV PhaseStuff 
    end 
    clear LFP
end

%% Plotting script 

clear; 
experiments = get_experiment_redux;
experiments = experiments([80:138]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59);
areas ={'Str', 'TH3'}; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_3Probe_PLVramp\'; 

PPC_pre_Str = []; 
PPC_pre_TH = []; 
PPC_stim_Str = []; 
PPC_stim_TH = []; 

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 

    for area_idx = 1 : size(areas,2)        
    area = char(areas(area_idx)); 
    
        % load and get variables 
        if strcmp(area, 'Str') && experiment.target2 == 1
            load([folder2save area '\' experiment.name])
            PPC_pre_Str = [PPC_pre_Str, PhaseStuff.PPC_pre]; 
            PPC_stim_Str = [PPC_stim_Str, PhaseStuff.PPC_stim]; 
        elseif strcmp(area, 'TH3') && experiment.target3 == 1
            PPC_stim_TH = [PPC_stim_TH, PhaseStuff.PPC_pre]; 
            PPC_pre_TH = [PPC_pre_TH, PhaseStuff.PPC_stim]; 
        end 
    end 
end 

x = [1; 2; 3; 4; 5; 6]; 

PPCstrplot(:,:,1) = PPC_pre_Str; 
PPCstrplot(:,:,2) = PPC_stim_Str; 
PPCstrplot = permute(PPCstrplot, [2 3 1]); 
PPCstrplot = squeeze(reshape(PPCstrplot, size(PPCstrplot,1), size(PPCstrplot,2)*size(PPCstrplot,3), [])); 
figure; 
violinplot(PPCstrplot, x, 'ViolinAlpha', 0.7, 'Width', 0.2); 
ylabel('PPC'); xticklabels({'4-12 pre', '4-12 stim', '12-30 pre', '12-30 stim', '30-70 pre', '30-70 stim'}); 
set(gca, 'FontSize', 12); title('Str to ACCsup stim')
% ylim([-0.2 0.2])
yline(0);
plot([1.2,1.8], [PPCstrplot(:,1),PPCstrplot(:,2)], 'k')
plot([3.2,3.8], [PPCstrplot(:,3),PPCstrplot(:,4)], 'k')
plot([5.2,5.8], [PPCstrplot(:,5),PPCstrplot(:,6)], 'k')

PPCthplot(:,:,1) = PPC_pre_TH; 
PPCthplot(:,:,2) = PPC_stim_TH; 
PPCthplot = permute(PPCthplot, [2 3 1]); 
PPCthplot = squeeze(reshape(PPCthplot, size(PPCthplot,1), size(PPCthplot,2)*size(PPCthplot,3), [])); 
figure; 
violinplot(PPCthplot, x, 'ViolinAlpha', 0.7, 'Width', 0.2); 
ylabel('PPC'); xticklabels({'4-12 pre', '4-12 stim', '12-30 pre', '12-30 stim', '30-70 pre', '30-70 stim'}); 
set(gca, 'FontSize', 12); title('TH to ACCsup stim')
% ylim([-0.2 0.2])
yline(0);
plot([1.2,1.8], [PPCthplot(:,1),PPCthplot(:,2)], 'k')
plot([3.2,3.8], [PPCthplot(:,3),PPCthplot(:,4)], 'k')
plot([5.2,5.8], [PPCthplot(:,5),PPCthplot(:,6)], 'k')

%% Plotting script 

clear; 
experiments = get_experiment_redux;
experiments = experiments([80:138]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 87);
areas ={'Str', 'TH3'}; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_3Probe_PLVramp\'; 

PPC_pre_Str = []; 
PPC_pre_TH = []; 
PPC_stim_Str = []; 
PPC_stim_TH = []; 

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 

    for area_idx = 1 : size(areas,2)        
    area = char(areas(area_idx)); 
    
        % load and get variables 
        if strcmp(area, 'Str') && experiment.target2 == 1
            load([folder2save area '\' experiment.name])
            PPC_pre_Str = [PPC_pre_Str, PhaseStuff.PPC_pre]; 
            PPC_stim_Str = [PPC_stim_Str, PhaseStuff.PPC_stim]; 
        elseif strcmp(area, 'TH3') && experiment.target3 == 1
            PPC_stim_TH = [PPC_stim_TH, PhaseStuff.PPC_pre]; 
            PPC_pre_TH = [PPC_pre_TH, PhaseStuff.PPC_stim]; 
        end 
    end 
end 

x = [1; 1.5; 3; 3.5; 5; 5.5]; 

PPCstrplot(:,:,1) = PPC_pre_Str; 
PPCstrplot(:,:,2) = PPC_stim_Str; 
PPCstrplot = permute(PPCstrplot, [2 3 1]); 
PPCstrplot = squeeze(reshape(PPCstrplot, size(PPCstrplot,1), size(PPCstrplot,2)*size(PPCstrplot,3), [])); 
figure; 
violinplot(PPCstrplot, x, 'ViolinAlpha', 0.7, 'Width', 0.2); 
ylabel('PPC'); xticklabels({'4-12 pre', '4-12 stim', '12-30 pre', '12-30 stim', '30-70 pre', '30-70 stim'}); 
set(gca, 'FontSize', 12); title('Str to ACCsup stim ctrl')
plot([1.2,1.8], [PPCstrplot(:,1),PPCstrplot(:,2)], 'k')
plot([3.2,3.8], [PPCstrplot(:,3),PPCstrplot(:,4)], 'k')
plot([5.2,5.8], [PPCstrplot(:,5),PPCstrplot(:,6)], 'k')
% ylim([-0.2 0.2])
yline(0);


PPCthplot(:,:,1) = PPC_pre_TH; 
PPCthplot(:,:,2) = PPC_stim_TH; 
PPCthplot = permute(PPCthplot, [2 3 1]); 
PPCthplot = squeeze(reshape(PPCthplot, size(PPCthplot,1), size(PPCthplot,2)*size(PPCthplot,3), [])); 
figure; 
violinplot(PPCthplot, x, 'ViolinAlpha', 0.7, 'Width', 0.2); 
ylabel('PPC'); xticklabels({'4-12 pre', '4-12 stim', '12-30 pre', '12-30 stim', '30-70 pre', '30-70 stim'}); 
set(gca, 'FontSize', 12); title('TH to ACCsup stim ctrl')
% ylim([-0.2 0.2])
yline(0);
plot([1.2,1.8], [PPCthplot(:,1),PPCthplot(:,2)], 'k')
plot([3.2,3.8], [PPCthplot(:,3),PPCthplot(:,4)], 'k')
plot([5.2,5.8], [PPCthplot(:,5),PPCthplot(:,6)], 'k')

