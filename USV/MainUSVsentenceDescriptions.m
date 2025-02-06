%% 

% length 
% weight: number of 1s or 0s in the entire string 
% run-lenght statistics: maximal consecutive blocks of 0s or 1s 
%     can also loook at the disdtribution of run length (hpw many runs of
%     of each) 
% transition count: how many times the sequence switches 
% periodicity: whether the string repeats itself 
% sub-word complexity/factor complexity: "richness" measure, distinct substrings of a given k (ask for a function)  
% algorithmic (kolmogorov) complexity 
% Lempel-ziv complexity: roughly, how many "patterns" appear as you scan from left -> right.
% compression ratio: real-world compressor (eg. DEFLATE, LZMA) and see how many butyes the sequence takes when compressed, 
%     similar sequences may compress similarly, or the concatenation might commpress better if they share similar patterns. 


clear
% get experiments
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);

% get table with t-sne labels 
T = readtable('Q:\Personal\Tony\Analysis\ephysUSVfeatures_pooled_tsne.csv', 'Delimiter', ',');

% params 
minInterSyInt = 5000; % in ms 

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
    
            % make it a table 
            mouse = repmat({experiment.animal_ID}, [size(songs, 1) 1]); 
            file = repmat({experiment.USV}, [size(songs, 1) 1]);
            temp = [table(mouse) table(file) array2table(songs, 'VariableNames', {'start', 'stop'}) table(sentences)]; 
            % add to total table 
            sen_tot = [sen_tot; temp]; 
        end 
        % clear some variables 
        clearvars syllables Calls temp mouse file

    end % call tables size end 
end % experiment loop end 

writetable(sen_tot, 'Q:\Personal\Tony\Analysis\ephysUSVsentences.csv', 'QuoteStrings', true);










