function USVpower = getUSVpower(experiments, T, sigparams, psparams, repeat_calc, folder2save)
% Tony July 2024 
% 
% input: 
%     experiments: all experiments of the animal. Can be one or multiple 
%     T: all USV sentence of the animal, .csv loaded as matlab table  
%     minInterSyInt: mininum interval between calls to not be merged together. Also the timewindow before and after call onset. 
%     sigparams: 
%         ch2load
%         cores
%         fs % sampling rate from data
%         downsampling_factor % downsample for LFP analysis
%         high_cut % nyquist frequency: the number of data points per second. Max high cut should be half of sampling frequency
%         low_cut 
%         ExtractMode % extract from neuralynx into matlab
%         signal length to cut, in second
%     repeat_calc: whether to overwrite old results or not 
%     folder2save: 
% 
% output: 
%     struct of pWelch specturm, ch x freq x trials 


% check if already computed 
if repeat_calc == 0 && exist([folder2save experiments(1).animal_ID, '.mat'])
%     disp([experiments(1).animal_ID ' already computed'])
    load([folder2save experiments(1).animal_ID, '.mat']); % if so, just load 

% if not, compute
else 
    % unpack params: 
    ch2load = sigparams.ch2load; 
    cores = sigparams.cores; 
    fs = sigparams.fs; % sampling rate from data
    downsampling_factor = sigparams.downsampling_factor; % downsample for LFP analysis
    low_cut = sigparams.low_cut; 
    ExtractMode = sigparams.ExtractMode; % extract from neuralynx into matlab
    length = sigparams.length; % length for power spectra computation 
    fs_LFP = fs / downsampling_factor;
    high_cut = fs_LFP / 2; % nyquist frequency: the number of data points per second. Max high cut should be half of sampling frequency

    windowSize = psparams. windowSize;
    overlap = psparams. overlap;
    nfft = psparams. nfft;
    maxFreq = psparams. maxFreq;

    % convert timestamp to the same as LFP
    T.start = round(T.start / (1000 / fs_LFP)); 
    T.stop = round(T.stop / (1000 / fs_LFP)); 
  
    % looping through experiments
    baseline_tot = []; 
    prep_tot = []; 
    during_tot = []; 
    
    for exp_idx = 1 : size(experiments, 2) 
        experiment = experiments(exp_idx); 
    
        % load signal 
%         disp(['loading signal for ' experiment.animal_ID ' exp ' num2str(exp_idx)])
        parfor (channel = ch2load, cores) 
            file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
            [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
            signal = ZeroPhaseFilter(signal, fs, [low_cut high_cut]); % origianlly 0.1
            LFP(channel, :) = signal(1 : downsampling_factor : end);
        end 

        % set USV file 
        T_exp = T(strcmp(T.usvfile, experiment.USV), :);

        % loop through every channel call to compute spectra 
        for si = 1 : size(T_exp, 1) 
            for ch = ch2load
                [baseline(ch, :), freq] = pWelchSpectrum(LFP(ch, (T_exp.start(si) - length*5*fs_LFP):(T_exp.start(si) - length*4*fs_LFP - 1)), windowSize, overlap, nfft, fs_LFP, maxFreq);
                [prep(ch, :), ~] = pWelchSpectrum(LFP(ch, (T_exp.start(si) - length*1*fs_LFP):(T_exp.start(si) - 1)), windowSize, overlap, nfft, fs_LFP, maxFreq);
                if (T_exp.stop(si) - T_exp.start(si)) > fs_LFP % if the call was long enough 
                    [during(ch, :), ~] = pWelchSpectrum(LFP(ch, T_exp.start(si):(T_exp.start(si) + length*fs_LFP - 1)), windowSize, overlap, nfft, fs_LFP, maxFreq);
                else 
                    during(ch, :) = NaN([1, high_cut/fs_LFP*nfft + 1]); 
                end 
            end 
            baseline_tot = cat(3, baseline_tot, baseline); 
            prep_tot  = cat(3, prep_tot, prep); 
            during_tot = cat(3, during_tot, during); 
        end 
        clear LFP 
    end % exp loop end 

    % put everything in a structure 
    USVpower.baseline = baseline_tot; 
    USVpower.prep = prep_tot;
    USVpower.during = during_tot; 
    USVpower.freq = freq; 
    USVpower.note = 'ch x freqs x trials';

    % save data 
    if ~exist(folder2save, 'dir') 
        mkdir(folder2save) 
    end 
    save([folder2save experiment.animal_ID], 'USVpower')

end % repeat calc if end 
end % function end 