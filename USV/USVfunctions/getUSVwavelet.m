function USVwavelet = getUSVwavelet(experiments, minInterSyInt, sigparams, repeat_calc, folder2save)
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
    fs_LFP = fs / downsampling_factor;
    high_cut = fs_LFP / 2; % nyquist frequency: the number of data points per second. Max high cut should be half of sampling frequency

    % initialize a variable 
    usvmat_tot = []; 
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
            
            % adjust so that the songs timestaps are in LFP frequency 
            songs = round(songs/(1000/fs_LFP)); 
    
            % make a USV tensor, Ch X (double song inter) X trials
            usvmat = zeros(max(ch2load), 2*(minInterSyInt/1000*fs_LFP), size(songs, 1)); 
            for song_idx = 1 : size(songs, 1)
                usvmat(:, :, song_idx) = LFP(:, (songs(song_idx) - (minInterSyInt/1000*fs_LFP) + 1):(songs(song_idx) + (minInterSyInt/1000*fs_LFP)));
            end
            % concatenate together, from last experiments 
            usvmat_tot = cat(3, usvmat_tot, usvmat);
            clear usvmat LFP 
        end 
    end 

    % wavelet transform, loop through every channel and every call 
    if size(usvmat_tot, 3) > 1
        disp('wavelet tranforming...')
        for ch = ch2load 
            for usv = 1: size(usvmat_tot, 3) 
                % wavelet transform 
                [cfs, freqs] = cwt(usvmat_tot(ch, :, usv), 'amor', fs_LFP, 'FrequencyLimits', [low_cut high_cut], 'VoicesPerOctave', 20);
                chwl(:, :, usv) = abs(cfs); % abs reserves amplitude and disgard phase information 
            end 
            % average across USV calls 
            chwl = median(chwl, 3);

            % save it in a struct
            USVwavelet.freqs = freqs; 
            USVwavelet.fs = fs_LFP; 
            USVwavelet.(['ch' num2str(ch)]) = chwl; % dynamically named 
            clearvars chwl 
        end 
    else 
        USVwavelet.note = 'No calls!'; 
    end 

    % save data 
    if ~exist(folder2save, 'dir') 
        mkdir(folder2save) 
    end 
    save([folder2save experiment.animal_ID], 'USVwavelet')

end % repeat calc if end 
end % function end 

