%% USV sentence detector 

% take T-SNE cluster output of all USV calls and generate dataframe with sentences 
% 
% input: (csv's with calls and features) 
%     - ephysUSVfeatures_pooled_tsne.csv
%     - PharmUSV_pooled_tsne.csv
% 
% output: (csv's with sentences and features) 
%     - ephysUSVsentences.csv 
%     - pharmUSVsentences.csv    

clear
% get experiments
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);

% get table with t-sne labels 
T = readtable('Q:\Personal\Tony\Analysis\USV_csvs\ephysUSVfeatures_pooled_tsne.csv', 'Delimiter', ',');

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
            % in case the last one starts too late, drop 
            while songs(end, 1) + minInterSyInt > audiodata.Duration*1000
                songs(end, :) = []; 
                sentences(end) = []; 
            end 
    
            % make it a table 
            mouse = repmat({experiment.animal_ID}, [size(songs, 1) 1]); 
            file = repmat({experiment.USV}, [size(songs, 1) 1]);
            age = repmat({experiment.age}, [size(songs, 1) 1]);
            temp = [table(mouse) table(age) table(file) array2table(songs, 'VariableNames', {'start', 'stop'}) table(sentences)]; 
            % add to total table 
            sen_tot = [sen_tot; temp]; 
        end 
        % clear some variables 
        clearvars syllables Calls temp mouse file

    end % call tables size end 
end % experiment loop end 

% save it as a df 
% writetable(sen_tot, 'Q:\Personal\Tony\Analysis\USV_csvs\ephysUSVsentences.csv', 'QuoteStrings', true);

sen_tot.duration = sen_tot.stop - sen_tot.start; 
sen_tot.length = strlength(sen_tot.sentences); 
sen_tot.count0 = count(sen_tot.sentences, '0'); 
sen_tot.frac0 = sen_tot.count0 ./ sen_tot.length; 

df0 = sen_tot(sen_tot.frac0 == 0, :);
df1 = sen_tot(sen_tot.frac0 == 1, :);
dfm = sen_tot((sen_tot.frac0 < 1) & (sen_tot.frac0 > 0), :);

% % some descriptive stats 
% % duration 
% figure; histogram(df0.duration) 
% xlabel('duration (ms)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('type-0 only sentence')
% 
% figure; histogram(df1.duration) 
% xlabel('duration (ms)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('type-1 only sentence')
% 
% figure; histogram(dfm.duration) 
% xlabel('duration (ms)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('mixed sentence')
% 
% % number of calls per sentence 
% figure; histogram(df0.length)
% xlabel('length (number of calls per sentence)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('type-0 only sentence')
% 
% figure; histogram(df1.length)
% xlabel('length (number of calls per sentence)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('type-1 only sentence')
% 
% figure; histogram(dfm.length)
% xlabel('length (number of calls per sentence)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('mixed sentence')


%% spike plotting section 
% 
% % select which df to plot with 
% df = dfm; 
% 
% folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
% BrainArea = 'TH'; 
% if strcmp(BrainArea, 'TH')
%     experiments = experiments(ismember({experiments.USV}, unique(df.file))); 
% end 
% 
% map4plot = viridis(100);
% Gwindow = gausswin(1001, 5); % gaussian window 
% Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
% % figure; plot(Gwindow)
% 
% % get unique animal numbers 
% animals = extractfield(experiments, 'animal_ID');
% animals = animals(~cellfun('isempty', animals));
% animals = unique(cellfun(@num2str, animals, 'un', 0));
% 
% % initialize 
% usvmat_tot = []; % cells X time, averaged over calls on an animal basis 
% 
% % loop through animals 
% for a_idx = 1 : size(animals, 2)
%     animal = animals{a_idx};
%     df_a = df(strcmp(df.mouse, animal), :);
%     % get experiments of this specific animal 
%     experiments4mouse = experiments(ismember({experiments.USV}, unique(df_a.file))); 
% 
%     % get a list of all cells 
%     cells = [];
%     for exp_idx = 1 : size(experiments4mouse, 2) 
%         experiment = experiments4mouse(exp_idx); 
%         load([folder4SM BrainArea '\' experiment.name]); 
%         cells = union(cells, clusters); 
%         clearvars spike_matrix clusters
%     end 
% 
%     % initialize the USV spike matrix for this animal, cell x time x sen 
%     temp = []; 
%     % loop through sentences and get brain activity 
%     for s_idx = 1 : size(df_a, 1)
%         % specify sentence 
%         sentence = df_a(s_idx, :);
%         % find experiment
%         experiment = experiments(strcmp({experiments.USV}, sentence.file)); 
%         % load spike matrix and get neural activity 
%         load([folder4SM BrainArea '\' experiment.name]); 
% 
%         % zero pad spike matrix at the end in case it's short 
%         % because the tailing calls has been cleared, short spike matrix necessarily means that there's no spikes, not the lack of recording 
%         if size(spike_matrix, 2) < sentence.start + minInterSyInt
%             spike_matrix(:, end:(sentence.start + minInterSyInt)) = 0; 
%         end 
% 
%         % cut the part of spike matrix of this particular sentence and        
%         temp(logical(sum(cells == clusters, 2)), :, s_idx) = spike_matrix(:, (sentence.start-minInterSyInt+1) : (sentence.start + minInterSyInt));
%         temp(~logical(sum(cells == clusters, 2)), :, s_idx) = 0; 
%         clearvars spike_matrix clusters
%     end 
% 
%     % average across calls and assign to total usvmat 
%     usvmat_tot = [usvmat_tot; mean(temp, 3)]; 
% 
% 
% end 
% 
% % average across songs, covolution, and zscore 
% usvmat_tot_conv = downsamp_convolve(usvmat_tot, Gwindow, 1); 
% z2plot = zscore(usvmat_tot_conv, [], 2); 
% 
% idx_sorted = sort_peak_time(z2plot, 500); % sort 
% % sorted raster justified to song onset 
% figure; 
% imagesc((-minInterSyInt + 1:minInterSyInt)/1000, 1:size(z2plot, 1), flipud(z2plot(idx_sorted, :))); colormap(map4plot) % plot
% xline(0, ':w','LineWidth', 1.5); ylabel('Cells'); 
% set(gca, 'FontSize', 14, 'FontName', 'Arial', 'TickDir', 'out')
% xticks([-4 -3 -2 -1 0 1 2 3 4]); xlabel('Time (s)');
% title([BrainArea], 'FontWeight','normal') 
% xlim([-minInterSyInt+300 minInterSyInt-300]/1000)
% 
% % line profile 
% figure; 
% subplot(211); % zscore
% boundedline((-minInterSyInt + 1 : minInterSyInt)/1000, mean(z2plot), std(z2plot) ./ sqrt(size(z2plot, 1)));
% lines = findobj(gcf,'Type','Line');
% for i = 1:numel(lines)
%   lines(i).LineWidth = 1.5;
% end
% xline(0, ':k','LineWidth', 1); 
% xlim([-minInterSyInt+300 minInterSyInt-300]/1000)
% xticks([-4 -3 -2 -1 0 1 2 3 4]); xlabel('Time (s)');
% ylabel('z-score fr'); 
% set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 1); 
% title([BrainArea])
% subplot(212); % actual fr 
% boundedline((-minInterSyInt + 1 : minInterSyInt)/1000, mean(usvmat_tot_conv), std(usvmat_tot_conv) ./ sqrt(size(usvmat_tot_conv, 1)));
% lines = findobj(gcf,'Type','Line');
% for i = 1:numel(lines)
%   lines(i).LineWidth = 1.5;
% end
% xline(0, ':k','LineWidth', 1); 
% xlim([-minInterSyInt+300 minInterSyInt-300]/1000)
% xticks([-4 -3 -2 -1 0 1 2 3 4]); xlabel('Time (s)');
% ylabel('fr (Hz)'); 
% set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 1); 
% 

%% Pharm section 

clear
% get table with t-sne labels 
T = readtable('Q:\Personal\Tony\Analysis\USV_csvs\PharmUSV_pooled_tsne.csv', 'Delimiter', ',');

% get experiments
experiments = readtable('Q:\Personal\Tony\Analysis\USV_csvs\PharmUSV.xlsx');
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
            mouse = repmat(experiment.mouse, [size(songs, 1) 1]); 
            file = repmat(experiment.file, [size(songs, 1) 1]);
            age = repmat(experiment.age, [size(songs, 1) 1]);
            C21 = repmat(T_exp.C21(1), [size(songs, 1) 1]); 
            temp = [table(mouse) table(age) table(C21) array2table(songs, 'VariableNames', {'start', 'stop'}) table(sentences)...
                table(lowfreqs) table(freqranges) table(meanpowers) table(file)]; 
            % add to total table 
            sen_tot = [sen_tot; temp]; 
        end 
        % clear some variables 
        clearvars syllables Calls temp mouse file

    end % call tables size end 
end % experiment loop end 

% save it as a df 
writetable(sen_tot, 'Q:\Personal\Tony\Analysis\USV_csvs\PharmUSVsentences.csv', 'QuoteStrings', true);

% % reading test 
% clear; 
% X = readtable('Q:\Personal\Tony\Analysis\PharmUSVsentences.csv', 'Delimiter', ',')

% % example code of how to convert it back to number arrays 
% % Replace commas with spaces to allow conversion
% charStr = strrep(X.lowfreqs{72}, ',', ' ');
% % Convert to numeric array
% numArray = str2num(charStr);  % str2double does not work on space-separated lists

% sen_tot.duration = sen_tot.stop - sen_tot.start; 
% sen_tot.length = strlength(sen_tot.sentences); 
% sen_tot.count0 = count(sen_tot.sentences, '0'); 
% sen_tot.frac0 = sen_tot.count0 ./ sen_tot.length; 
% 
% df0 = sen_tot(sen_tot.frac0 == 0, :);
% df1 = sen_tot(sen_tot.frac0 == 1, :);
% dfm = sen_tot((sen_tot.frac0 < 1) & (sen_tot.frac0 > 0), :);
% 
% % some descriptive stats 
% % duration 
% figure; histogram(df0.duration) 
% xlabel('duration (ms)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('type-0 only sentence')
% 
% figure; histogram(df1.duration) 
% xlabel('duration (ms)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('type-1 only sentence')
% 
% figure; histogram(dfm.duration) 
% xlabel('duration (ms)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('mixed sentence')
% 
% % number of calls per sentence 
% figure; histogram(df0.length)
% xlabel('length (number of calls per sentence)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('type-0 only sentence')
% 
% figure; histogram(df1.length)
% xlabel('length (number of calls per sentence)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('type-1 only sentence')
% 
% figure; histogram(dfm.length)
% xlabel('length (number of calls per sentence)')
% ylabel('count')
% set(gca, 'YScale', 'log')
% title('mixed sentence')






