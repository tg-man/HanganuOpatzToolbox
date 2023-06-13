function StimRampCoh = getRampCoherence(experiment, LFP1, LFP2, pre, stim, params, folder2save, repeatCalc, save_data)
% coherence pre and during a ramp stimulation, adapted from getCoherence 
% inputs: 
%         - experiment: your excel 
%         - LFP1 and LFP2: signals of 1xN dimension 
%         - pre & stim: matrices of timestamps, 2 columns. Must be the same size! 
%         - params: see below 
%         - folder2save: must be the subfolder of the two brain regions, otherwise you won't know where the file comes from 

if repeatCalc == 0 && exist(strcat(folder2save, experiment.name, '.mat'), 'file')
    load(strcat(folder2save, experiment.name))    
else 
    % unpack params
    fs = params.fs; 
    win_length = params.win_length; 
    overlap = params.overlap; 
    nfft = params.nfft;
    
    % initialize variables
    Coherence_pre = []; 
    Coherency_pre = []; 
    CohShuff_pre = []; 
    CohyShuff_pre = []; 
    Coherence_stim = []; 
    Coherency_stim = []; 
    CohShuff_stim = []; 
    CohyShuff_stim = []; 
   
    % loop through each ramp stim and computer coherence 
    for ramp_idx = 1 : size(stim, 1)
        
        % select part of the signal for this iteration
        LFP1_pre = LFP1(pre(ramp_idx,1):pre(ramp_idx,2));
        LFP2_pre = LFP2(pre(ramp_idx,1):pre(ramp_idx,2));
        LFP1_stim = LFP1(stim(ramp_idx,1):stim(ramp_idx,2));
        LFP2_stim = LFP2(stim(ramp_idx,1):stim(ramp_idx,2));
        
        % compute number of windows 
        nWindows = floor(length(LFP1_stim) / (fs * win_length)); 
                
        % cut the two signals to fit window length
        LFP1_pre = LFP1_pre(1 : nWindows * win_length * fs);
        LFP2_pre = LFP2_pre(1 : nWindows * win_length * fs);
        LFP1_stim = LFP1_stim(1 : nWindows * win_length * fs);
        LFP2_stim = LFP2_stim(1 : nWindows * win_length * fs);
    
        % create a shuffled version of one of the two signals, for both pre and stim 
        signal_shuffled_pre = reshape(LFP2_pre, nWindows, fs * win_length);
        signal_shuffled_pre = reshape(signal_shuffled_pre(: ,randperm(fs * win_length)), 1, []);
        signal_shuffled_stim = reshape(LFP2_stim, nWindows, fs * win_length);
        signal_shuffled_stim = reshape(signal_shuffled_stim(:, randperm(fs * win_length)), 1, []);
%         
%         signal_shuffled_pre = LFP2_pre(randperm(length(LFP2_pre))); 
%         signal_shuffled_stim = LFP2_stim(randperm(length(LFP2_stim))); 
%         
        % compute coherence and coherency on the two signals & on the shuffled one
        [Coh_pre, Cohy_pre, ~] = computeCoherence(LFP1_pre, LFP2_pre, win_length * fs, overlap * fs, nfft, fs);
        [CohSh_pre, CohySh_pre, ~] = computeCoherence(LFP1_pre, signal_shuffled_pre, win_length * fs, overlap * fs, nfft, fs);
        [Coh_stim, Cohy_stim, freqs] = computeCoherence(LFP1_stim, LFP2_stim, win_length * fs, overlap * fs, nfft, fs);
        [CohSh_stim, CohySh_stim, ~] = computeCoherence(LFP1_stim, signal_shuffled_stim, win_length * fs, overlap * fs, nfft, fs);
        
        % add it to the next row of a matrix
        Coherence_pre = [Coherence_pre, Coh_pre]; 
        Coherency_pre = [Coherency_pre, Cohy_pre]; 
        CohShuff_pre = [CohShuff_pre, CohSh_pre]; 
        CohyShuff_pre = [CohyShuff_pre, CohySh_pre]; 
        
        Coherence_stim = [Coherence_stim, Coh_stim]; 
        Coherency_stim = [Coherency_stim, Cohy_stim]; 
        CohShuff_stim = [CohShuff_stim, CohSh_stim]; 
        CohyShuff_stim = [CohyShuff_stim, CohySh_stim];  
        
    end 

    % put stuff in a structure
    StimRampCoh.Coherence_pre = Coherence_pre;
    StimRampCoh.Coherency_pre = Coherency_pre;
    StimRampCoh.CohShuff_pre = CohShuff_pre;
    StimRampCoh.CohyShuff_pre = CohyShuff_pre;
    StimRampCoh.freqs = freqs; 
    StimRampCoh.Coherence_stim = Coherence_stim;
    StimRampCoh.Coherency_stim = Coherency_stim;
    StimRampCoh.CohShuff_stim = CohShuff_stim;
    StimRampCoh.CohyShuff_stim = CohyShuff_stim;
    
    % save everything
    if save_data == 1
        if ~ exist(folder2save, 'dir')
            mkdir(folder2save)
        end
        save(strcat(strcat(folder2save, experiment.name)), 'StimRampCoh')
    end
    
end 
end 

%% helper function that computes coherence
function [Coherence, Coherency, freqs] = ...
    computeCoherence(signal_1, signal_2, window_length, overlap, nfft, fs)
	% calculate psd and cpsd (cross power spectral density)
	[PSD1, ~] = pwelch(signal_1, hanning(window_length), overlap, nfft, fs);
	[PSD2, ~] = pwelch(signal_2, hanning(window_length), overlap, nfft, fs);
	[CPSD, freqs] = cpsd(signal_1, signal_2, hanning(window_length), overlap, nfft, fs);
	% compute coherence and coherency
	Coherence = CPSD ./ sqrt(PSD1 .* PSD2);
	Coherency = abs(imag(Coherence));
end