%% generate pooled dataframe for all USVs from all animals 

clear
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);

% get unique animal numbers
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

% initialize 
statsvars = {'PeakFreq_kHz_', 'Slope_kHz_s_', 'Sinuosity', 'MeanPower_dB_Hz_'};
calltot = []; 

% loop through experiments
for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % load Calls.mat file 
    load([experiment.USV_path experiment.USV]);
    Calls = Calls(Calls.Accept, :);
    % check labels and adjust timestamps 
    if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
        Calls.Box(:, 1) = Calls.Box(:, 1) - Calls.Box(1, 1); % adjust timestamps to align with ephys 
        Calls(1, :) = []; % remove first timestamp, aritificially added start 
        Calls(end, :) = []; % remove last timestemp, ariticially added end 
    end 

    % load Stats file 
    stats = readtable([experiment.USV_path 'Stats\' experiment.USV '_Stats.xlsx']);
    % check label and remove added start and end markers 
    if strcmp(stats.Label(1), '9') && strcmp(stats.Label(end), '8')
        stats(1, :) = []; 
        stats(end, :) = []; 
    end 

    % grab features 
    if size(stats, 1) == size(Calls, 1) % check file size agreement
        mouse = repmat({experiment.animal_ID}, [size(stats, 1) 1]);
        age = repmat(experiment.age, [size(stats, 1) 1]);
        length = Calls.Box(:, 3); 
        lowfreq = Calls.Box(:, 2); 
        highfreq = Calls.Box(:, 2) + Calls.Box(:, 4); 
        freqrange = Calls.Box(:, 4); 
        file = repmat({experiment.USV}, [size(stats, 1) 1]);
        temp = [table(mouse) table(age) table(length, lowfreq, highfreq, freqrange)...
            stats(:, statsvars) table(file)]; %% update code for new stats output 
        % add to total variable
        calltot = [calltot; temp];
    else 
        disp([experiment.animal_ID ', ' experiment.name ' file sizes mismatch!'])
    end 

end 

writetable(calltot, 'Q:\Personal\Tony\Analysis\USV_csvs\old\ephysUSVfeatures.csv', 'QuoteStrings', true);
% test = readtable('Q:\Personal\Tony\Analysis\PharmUSV_calltot_4.csv', 'Delimiter', ',');


