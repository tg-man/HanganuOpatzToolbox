%% generate data frame for HMM for Mattia 
% first load ephys single call data and group sentence 
% then load pharm single call data and group sentence 
% then combine and save

%% ephys section 

clear
% get experiments
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);

% get table with t-sne labels 
T = readtable('Q:\Personal\Tony\Analysis\USV_csvs\ephysUSVfeatures_pooled_tsne.csv', 'Delimiter', ',');
T.tsne_label(T.tsne_label == 0) = 2; 

% params 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
minInterSyInt = 5000; % in ms 
post = 3000; % in ms 

% initialize
sen_tot = []; 

for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % load USV.mat file 
    load([experiment.USV_path  experiment.USV]);
    Calls = Calls(Calls.Accept, :);
    % check labels and adjust timestamps 
    if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
        Calls.Box(:, 1) = Calls.Box(:, 1) - Calls.Box(1, 1); % adjust timestamps to align with ephys 
        Calls(1, :) = []; % remove first timestamp, aritificially added start 
        Calls(end, :) = []; % remove last timestemp, ariticially added end
    else 
        disp([experiment.USV ' wrongly labeled!!!'])
    end 

    % filter big T file to match USV.mat file 
    T_exp = T(strcmp(T.file, experiment.USV), :);

    % merge calls if they are close enough together 
    if size(T_exp, 1) == size(Calls, 1) % check call size agrees 
        % create syllable time stamps here in miliseconds 
        syllables(:, 1) = round(Calls.Box(:,1)*1000); % extract beginning timestamps
        syllables(:, 2) = round(1000*(Calls.Box(:,1) + Calls.Box(:, 3))); % extract end timestamps
        % create another string variable for tsne labels here!  
        labels = string(T_exp.tsne_label);

        % then loop through, every time a syllable is connected, also append the tsne cluster labels as strings together 
        if ~isempty(syllables)
            songs = [];
            sentences = []; 
            song = syllables(1, :); 
            sentence = labels(1); 
            for sy_idx = 2 : size(syllables, 1) 
                if syllables(sy_idx, 1) - song(2) < minInterSyInt
                    song(2) = syllables(sy_idx, 2);
                    sentence = strcat(sentence, labels(sy_idx)); 
                else 
                    songs = [songs; song];
                    sentences = [sentences; sentence]; 
                    song = syllables(sy_idx, :); 
                    sentence = labels(sy_idx); 
                end 
            end 
            % There's always a song and sentence variable out of the loop
            songs = [songs; song]; % Keep this line!!! 
            sentences = [sentences; sentence]; % Keep this line!!! 
            
            % in case the first one starts too early, drop 
            if songs(1) < minInterSyInt
                songs(1,:) = []; 
                sentences(1) = []; 
            end
            % in case the last one starts too late, drop 
            while songs(end, 1) + minInterSyInt > audiodata.Duration*1000
                songs(end, :) = []; 
                sentences(end) = []; 
            end 
    
            % make it a table 
            if strcmp(experiment.Exp_type, 'baseline only')
                condition = 'baseline'; 
            elseif strcmp(experiment.Exp_type, 'opto') && any(~isnan(experiment.IUEconstruct))
                condition = 'opto'; 
            elseif strcmp(experiment.Exp_type, 'opto') && isnan(experiment.IUEconstruct)
                condition = 'opto_ctrl'; 
            end 
            mouse = repmat({experiment.animal_ID}, [size(songs, 1) 1]);
            condition = repmat({condition}, [size(songs, 1) 1]);
            file = repmat({experiment.USV}, [size(songs, 1) 1]);
            age = repmat(experiment.age, [size(songs, 1) 1]);
            temp = [table(mouse) table(age) table(file) table(condition) array2table(songs, 'VariableNames', {'start', 'stop'}) table(sentences)]; 

            % if opto, filter out sentences outside of ramp period
            if contains(condition(1), 'opto')
                % load stim properties 
                load([folder4stim experiment.name '_StimulationProperties_raw.mat']);
                % get timestamps for ramp period 
                ramps = strcmp(StimulationProperties_raw(:, 8), 'ramp');
                StimulationProperties_raw = StimulationProperties_raw(ramps, :); 
                stim = round(cell2mat([StimulationProperties_raw(1, 1) StimulationProperties_raw(end ,2)]) / 3.2); % /3.2 bc stim prop is in 3.2k Hz 
                stim(end) = stim(end) + post; % add some post last ramp laser 
                
                % filter out opto calls outside of ramp period 
                temp = temp((temp.start > stim(1)) & (temp.start < stim(2)), :);
            end 
            
            % add to total table 
            sen_tot = [sen_tot; temp]; 
        end 
        % clear some variables 
        clearvars syllables Calls temp mouse file condition ramps stim StimulationProperties_raw

    end % call tables size end 
end % experiment loop end 

df_ephys = sen_tot(:, {'mouse', 'age', 'condition', 'sentences', 'file'}); 
clearvars -except df_ephys

%% chemo section 

% get table with t-sne labels 
T = readtable('Q:\Personal\Tony\Analysis\USV_csvs\PharmUSV_pooled_tsne.csv', 'Delimiter', ',');
T.tsne_label(T.tsne_label == 0) = 2; 

% get experiments
experiments = readtable('Q:\Personal\Tony\Analysis\USV_csvs\Experiments_PharmUSV.xlsx');
experiments = experiments(experiments.exp_L == 1 & experiments.exp_R == 1,:);
experiments.exp_L = []; 
experiments.exp_R = []; 

% params 
minInterSyInt = 5000; % in ms 

folder4USV = 'Q:\Personal\Tony\Analysis\Results_USV\'; 

% initialize
sen_tot = []; 

for exp_idx = 1 : size(experiments, 1)
    experiment = experiments(exp_idx, :); 

    % filter big T file to match USV.mat file 
    T_exp = T(strcmp(T.File, [folder4USV char(experiment.file) '.mat']), :);

    % load USV.mat file 
    load([folder4USV char(experiment.file)]);
    Calls = Calls(Calls.Accept, :);

    % merge calls if they are close enough together 
    if size(T_exp, 1) == size(Calls, 1) % check call size agrees 
        % create syllable time stamps here in miliseconds 
        syllables(:, 1) = round(Calls.Box(:,1)*1000); % extract beginning timestamps
        syllables(:, 2) = round(1000*(Calls.Box(:,1) + Calls.Box(:, 3))); % extract end timestamps
        % create another string variable for tsne labels here!  
        labels = string(T_exp.tsne_label);
        lows = string(T_exp.lowfreq); 
        ranges = string(T_exp.freqrange); 
        powers = string(T_exp.meanpower); 

        % then loop through, every time a syllable is connected, also append the tsne cluster labels as strings together 
        if ~isempty(syllables)
            % initiate the aggregate variables 
            songs = []; 
            sentences = [];
            lowfreqs = []; 
            freqranges = []; 
            meanpowers = []; 

            % initiate the iterated variables 
            song = syllables(1, :);
            sentence = labels(1);
            lowfreq = lows(1); 
            freqrange = ranges(1); 
            meanpower = powers(1); 

            % loop through each call and check interval 
            for sy_idx = 2 : size(syllables, 1) 
                if syllables(sy_idx, 1) - song(2) < minInterSyInt % less than min interval, so concatenate 
                    song(2) = syllables(sy_idx, 2);
                    sentence = strcat(sentence, labels(sy_idx)); 
                    lowfreq = strjoin([lowfreq, lows(sy_idx)], ',');
                    freqrange = strjoin([freqrange, ranges(sy_idx)], ',');
                    meanpower = strjoin([meanpower, powers(sy_idx)], ','); 
                else % other case, conclude the iterated and start a new sentence 
                    % updated the aggregated variables 
                    songs = [songs; song];
                    sentences = [sentences; sentence]; 
                    lowfreqs = [lowfreqs; lowfreq];
                    freqranges = [freqranges; freqrange];
                    meanpowers = [meanpowers; meanpower]; 
                    % renew the iterated variables for the next loop 
                    song = syllables(sy_idx, :); 
                    sentence = labels(sy_idx); 
                    lowfreq = lows(sy_idx);
                    freqrange = ranges(sy_idx);
                    meanpower = powers(sy_idx); 
                end 
            end 
            % There's always a song and sentence variable out of the loop
            songs = [songs; song];                  % Keep this line!!! 
            sentences = [sentences; sentence];      % Keep this line!!! 
            lowfreqs = [lowfreqs; lowfreq];       % Keep this line!!!
            freqranges = [freqranges; freqrange]; % Keep this line!!!
            meanpowers = [meanpowers; meanpower]; % Keep this line!!! 

            % make it a table 
            if experiment.C21 == 0 
                condition = 'chemo_ctrl'; 
            elseif experiment.C21 == 1 
                condition = 'chemo'; 
            end 
            mouse = repmat(experiment.mouse, [size(songs, 1) 1]); 
            file = repmat(experiment.file, [size(songs, 1) 1]);
            condition = repmat({condition}, [size(songs, 1) 1]);
            age = repmat(experiment.age, [size(songs, 1) 1]);
            C21 = repmat(T_exp.C21(1), [size(songs, 1) 1]); 
            temp = [table(mouse) table(age) table(C21) array2table(songs, 'VariableNames', {'start', 'stop'}) table(sentences)...
                table(lowfreqs) table(freqranges) table(meanpowers) table(file) table(condition)]; 
            % add to total table 
            sen_tot = [sen_tot; temp]; 
        end 
        % clear some variables 
        clearvars syllables Calls temp mouse file

    end % call tables size end 
end % experiment loop end 

df_chemo = sen_tot(:, {'mouse', 'age', 'condition', 'sentences', 'file'}); 
clearvars -except df_ephys df_chemo

%% combine and process 

T = [df_ephys; df_chemo];

animals = unique(T.mouse);

df = []; 

for animal_idx = 1 : numel(animals)
    animal = animals(animal_idx); 

    T1 = T(strcmp(T.mouse, animal), :); 

    experiments = unique(T1.condition); 
    
    for exp_idx = 1 : numel(experiments) 
        experiment = experiments(exp_idx); 

        T2 = T1(strcmp(T1.condition, experiment), :); 

       
        mouse = T2.mouse(1); 
        age = T2.age(1); 
        condition = T2.condition(1); 
        callseq = strjoin(T2.sentences, '0'); 
    
        temp = [table(mouse) table(age) table(condition) table(callseq)];
    
        df = [df; temp]; 
        clearvars temp mouse age condition callseq

    end 
end 

df = table2struct(df);

save('Q:\Personal\Tony\forMattia\df4hmm.mat', 'df');

% writetable(df, 'Q:\Personal\Tony\forMattia\df4hmm.csv', 'QuoteStrings', true);

%% Do the combine again but filter out single calls 

clearvars -except df_ephys df_chemo
T = [df_ephys; df_chemo];

for i = 1 : size(T, 1)
    if strlength(T.sentences(i)) == 1
        del(i) = 0; 
    else 
        del(i) = 1; 
    end 
end 
T = T(logical(del), :);

animals = unique(T.mouse);

df = []; 

for animal_idx = 1 : numel(animals)
    animal = animals(animal_idx); 

    T1 = T(strcmp(T.mouse, animal), :); 

    experiments = unique(T1.condition); 
    
    for exp_idx = 1 : numel(experiments) 
        experiment = experiments(exp_idx); 

        T2 = T1(strcmp(T1.condition, experiment), :); 

       
        mouse = T2.mouse(1); 
        age = T2.age(1); 
        condition = T2.condition(1); 
        callseq = "0" + strjoin(T2.sentences, '0') + "0"; 
    
        temp = [table(mouse) table(age) table(condition) table(callseq)];
    
        df = [df; temp]; 
        clearvars temp mouse age condition callseq

    end 
end 

df = table2struct(df);

save('Q:\Personal\Tony\forMattia\df4hmm_NoIsoCalls.mat', 'df');

% save('Q:\Personal\Tony\forMattia\df4hmm_NoIsoCalls.mat', 'df');
% writetable(df, 'Q:\Personal\Tony\forMattia\df4hmm_NoIsoCalls.mat', 'QuoteStrings', true);


