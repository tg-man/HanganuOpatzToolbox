function USVpower = getUSVpower(experiments, minInterSyInt, sigparams, psparams, repeat_calc, folder2save)
% Tony July 2024 
% 
% input: 
%     experiments: all experiments of the animal. Can be one or multiple 
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
%     struct of wavelet transforms of all channels, averaged across calls 


% check if already computed 
if repeat_calc == 0 && exist([folder2save experiments(1).animal_ID, '.mat'])
    disp([experiments(1).animal_ID ' already computed'])
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
  
    % looping through experiments
    pre_tot = []; 
    post_tot = []; 
    during_tot = []; 
    for exp_idx = 1 : size(experiments, 2) 
        experiment = experiments(exp_idx); 
    
        % load USV file 
        syllables = []; % initialize 
        load([experiment.USV_path experiment.USV '.mat'])
        Calls = Calls(Calls.Accept == 1, :); % filter out rejected calls 
        % check labeling and extract numbers
        if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8  
            syllables(:, 1) = Calls.('Box')(:,1); % extract beginning timestamps
            syllables(:, 2) = Calls.('Box')(:,1) + Calls.('Box')(:, 3); % extract end timestamps
            syllables = round((syllables - syllables(1, 1)) * 1000); % justify recording beginning and convert to ms to fit to spike matrix 
            syllables(1, :) = []; % remove the first "call" - artificially added start
            syllables(end, :) = []; % remove the last "ca;;" - artificially added end 
        else 
             disp([experiment.USV ' start or end incorrectly labeled!']); 
        end 
    
        if size(syllables, 1) > 1 % check if the animal has vocalized at all
            % merge calls if they are close enough together 
            songs = []; 
            song = syllables(1, :); 
            for sy_idx = 2 : size(syllables, 1) 
                if syllables(sy_idx, 1) - song(2) < minInterSyInt
                    song(2) = syllables(sy_idx, 2);
                else 
                    songs = [songs; song]; 
                    song = syllables(sy_idx, :); 
                end 
            end 
            songs = [songs; song]; % still miliseconds here 
    
            % load signal 
            disp(['loading signal for ' experiment.animal_ID ' exp ' num2str(exp_idx)])
            parfor (channel = ch2load, cores) 
                file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
                [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
                signal = ZeroPhaseFilter(signal, fs, [low_cut high_cut]); % origianlly 0.1
                LFP(channel, :) = signal(1 : downsampling_factor : end);
            end 
    
            % in case the first one starts too early, drop 
            if songs(1) < minInterSyInt
                songs(1,:) = []; 
            end 
            % in case the last call is too late, drop
            if songs(end,1) + minInterSyInt > size(LFP,2)*1000/fs_LFP
                songs(end,:) = [];
            end 
            
            % adjust so that the songs timestamps are in LFP frequency 
            songs = round(songs/(1000/fs_LFP)); 

            % loop through every channel call to compute spectra 
            disp('power spectruming...')
            for si = 1 : size(songs, 1) 
                for ch = ch2load
                    [pre(ch, :), freq] = pWelchSpectrum(LFP(ch, (songs(si,1) - length*fs_LFP):(songs(si, 1) - 1)), windowSize, overlap, nfft, fs_LFP, maxFreq);
                    [post(ch, :), ~] = pWelchSpectrum(LFP(ch, (songs(si,2) + 1):(songs(si, 2) + length*fs_LFP)), windowSize, overlap, nfft, fs_LFP, maxFreq);
                    if (songs(si, 2) - songs(si, 1)) > fs_LFP % if the call was long enough 
                        [during(ch, :), ~] = pWelchSpectrum(LFP(ch, songs(si,1):(songs(si, 1) + length*fs_LFP - 1)), windowSize, overlap, nfft, fs_LFP, maxFreq);
                    else 
                        during(ch, :) = NaN([1, high_cut/fs_LFP*nfft + 1]); 
                    end 
                end 
                pre_tot  = cat(3, pre_tot, pre); 
                during_tot = cat(3, during_tot, during); 
                post_tot = cat(3, post_tot, post); 
            end 
            clear LFP 
        end % conditional end 
    end % exp loop end 

    % put everything in a structure 
    USVpower.pre = pre_tot;
    USVpower.during = during_tot; 
    USVpower.post = post_tot; 
    USVpower.freq = freq; 

    % save data 
    if ~exist(folder2save, 'dir') 
        mkdir(folder2save) 
    end 
    save([folder2save experiment.animal_ID], 'USVpower')

end % repeat calc if end 
end % function end 