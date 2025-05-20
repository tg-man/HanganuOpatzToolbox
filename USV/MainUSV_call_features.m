%% create df with all relevant features for single calls
% input: 
%     experiments 
%     DeepSqueak .mat and stats excel files 
% Output: csv, each row is a call, and relevant features as follow 
%     mouse 
%     age 
%     start
%     stop 
%     duration 
%     lowfreq
%     highfreq
%     freqrange 
%     peakfreq
%     meanpower
%     usvfile
%     recdur
%     condition
%     opsin 

clear
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);

% initialize final output 
calltot = []; 

% what to take out of the stats file
statsvars = {'PeakFreq_kHz_', 'MeanPower_dB_Hz_'};

% loop through experiments
for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % get experiment condition 
    if strcmp(experiment.Exp_type, 'baseline only')
        condition = 'baseline'; 
    elseif strcmp(experiment.Exp_type, 'opto') && (strcmp(experiment.ramp, 'ACCsup') || strcmp(experiment.ramp, 'ACCdeep'))
        condition = 'accstim'; 
    elseif strcmp(experiment.Exp_type, 'opto') && strcmp(experiment.ramp, 'Str')
        condition = 'strstim'; 
    end 

    % load Calls.mat file 
    load([experiment.USV_path experiment.USV]);
    Calls = Calls(Calls.Accept, :);
    % check labels and adjust timestamps 
    if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
        recdur = Calls.Box(end, 1) - Calls.Box(1,1);
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
    % time features from .mat, .mat tells the box but stats tells the controur which is unreliable 
    if size(stats, 1) == size(Calls, 1) % check file size agreement
        mouse = repmat({experiment.animal_ID}, [size(stats, 1) 1]);
        age = repmat(experiment.age, [size(stats, 1) 1]);
        start = Calls.Box(:, 1); 
        stop = Calls.Box(:, 1) + Calls.Box(:, 3); 
        duration = Calls.Box(:, 3); 
        lowfreq = Calls.Box(:, 2); 
        highfreq = Calls.Box(:, 2) + Calls.Box(:, 4); 
        freqrange = Calls.Box(:, 4); 
        usvfile = repmat({experiment.USV}, [size(stats, 1) 1]);
        recdur = repmat(recdur, [size(stats, 1) 1]);
        opsin = repmat({experiment.IUEconstruct}, [size(stats, 1) 1]);
        condition = repmat({condition}, [size(stats, 1) 1]);
        temp = [table(mouse) table(age) table(start, stop, duration, lowfreq, highfreq, freqrange)...
            stats(:, statsvars) table(usvfile, opsin, condition, recdur)]; %% update code for new stats output 
        % add to total variable
        calltot = [calltot; temp];
    else 
        disp([experiment.animal_ID ', ' experiment.name ' file sizes mismatch!'])
    end 

end 

% rename two columns for better variable name 
calltot.Properties.VariableNames{'PeakFreq_kHz_'} = 'peakfreq';
calltot.Properties.VariableNames{'MeanPower_dB_Hz_'} = 'meanpower';

% save 
writetable(calltot, 'Q:\Personal\Tony\Analysis\USV_csvs\ephysUSV_call_features.csv', 'QuoteStrings', true);