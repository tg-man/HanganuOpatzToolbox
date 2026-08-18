
% filter experiments 
clear
experiments = get_experiment_redux;
experiments = experiments(557:end); 
experiments = experiments([experiments.DiI] == 0);
experiments = experiments([experiments.laserpower] < 10);
experiments = experiments([experiments.age] > 8);

% stim folder 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 

T = []; 
% loop through experiments to load data into table 
for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % load USV data based on experiment type 
    if strcmp(experiment.Exp_type, 'baseline only')
        % load USV.mat 
        load([experiment.USV_path, experiment.USV]);
        Calls = Calls(Calls.Accept, :);
        % check labeling and process
        if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
            normdur = Calls.Box(end, 1) - Calls.Box(1,1);
            Calls(1, :) = []; % remove first timestamp, aritificially added start 
            Calls(end, :) = []; % remove last timestemp, ariticially added end 
        end
        % grab variables 
        mouse = string(experiment.animal_ID); 
        age = experiment.age; 
        condition = "baseline"; 
        opsin = experiment.IUEconstruct; 
        usvfile = string(experiment.USV); 
        callnum = size(Calls, 1); 
        temp = table(mouse, age, condition,opsin, usvfile, callnum, normdur,  ...
            'VariableNames', {'mouse', 'age', 'condition', 'opsin', 'usvfile', 'callnum', 'normdur'}); 
        T = [T; temp];

        clearvars Calls audiodata mouse age condition opsin usvfile callnum normdur

    elseif strcmp(experiment.Exp_type, 'opto')
        % load USV.mat 
        load([experiment.USV_path, experiment.USV]);
        Calls = Calls(Calls.Accept, :);
        % check labeling and process 
        if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
            Calls.Box(:, 1) = Calls.Box(:, 1) - (Calls.Box(1, 1) + Calls.Box(1, 3)); % align time 0 to click release of ephys start 
            Calls(1, :) = []; % remove first timestamp, aritificially added start 
            Calls(end, :) = []; % remove last timestemp, ariticially added end 
        end

        % load stim properties 
        load([folder4stim experiment.name '_StimulationProperties_raw.mat']);
        starts = cell2mat(StimulationProperties_raw(:, 1)) / 3200; 
        stops = cell2mat(StimulationProperties_raw(:, 2)) / 3200; 
        
        % check stim paradigm 
        if experiment.laserpower > 4
            % only calls during stim period 
            Calls = Calls(Calls.Box(:, 1) > starts(1) & Calls.Box(:, 1) < stops(end), :);
            % grab variables 
            mouse = string(experiment.animal_ID); 
            age = experiment.age; 
            condition = "pulse"; 
            opsin = experiment.IUEconstruct; 
            usvfile = string(experiment.USV); 
            callnum = size(Calls, 1); 
            normdur = stops(end) - starts(1); 
            temp = table(mouse, age, condition,opsin, usvfile, callnum, normdur,  ...
                'VariableNames', {'mouse', 'age', 'condition', 'opsin', 'usvfile', 'callnum', 'normdur'}); 
            T = [T; temp];
        
            % only calls during light off period 
            lightsoff = find(diff(starts) > 290); % find stim breaks
            Calls = Calls((Calls.Box(:, 1) > starts(1) & Calls.Box(:, 1) < starts(lightsoff(1))) | ...
                (Calls.Box(:, 1) > starts(lightsoff(1) + 1) & Calls.Box(:, 1) < stops(end)), ...
                :);
            % grab variables 
            mouse = string(experiment.animal_ID); 
            age = experiment.age; 
            condition = "pulse_lightsoff"; 
            opsin = experiment.IUEconstruct; 
            usvfile = string(experiment.USV); 
            callnum = size(Calls, 1); 
            normdur = (starts(lightsoff(1) + 1) - starts(lightsoff(1))) + (starts(lightsoff(2) + 1) - starts(lightsoff(2)));
            temp = table(mouse, age, condition,opsin, usvfile, callnum, normdur,  ...
                'VariableNames', {'mouse', 'age', 'condition', 'opsin', 'usvfile', 'callnum', 'normdur'}); 
            T = [T; temp];
            clearvars Calls audiodata mouse age condition opsin usvfile callnum normdur start stop ramps StimulationProperties_raw lightsoff
        
        elseif experiment.laserpower < 3
            Calls = Calls(Calls.Box(:, 1) > starts(1) & Calls.Box(:, 1) < stops(end), :);
            mouse = string(experiment.animal_ID);
            age = experiment.age; 
            condition = "constant"; 
            opsin = experiment.IUEconstruct; 
            usvfile = string(experiment.USV); 
            callnum = size(Calls, 1); 
            normdur = stops(end) - starts(1); 
            temp = table(mouse, age, condition,opsin, usvfile, callnum, normdur,  ...
                'VariableNames', {'mouse', 'age', 'condition', 'opsin', 'usvfile', 'callnum', 'normdur'}); 
            T = [T; temp];

             clearvars Calls audiodata mouse age condition opsin usvfile callnum normdur start stop ramps StimulationProperties_raw
        end 
    end 
end 




%% plot 

T.rate = T.callnum ./ (T.normdur ./60); 

Tnew = T(:, {'mouse', 'opsin', 'condition','rate'});
Tnew.opsin = string(Tnew.opsin);
Tnew.opsin(ismissing(Tnew.opsin)) = "Ctrl";
Twide = unstack(Tnew, 'rate', 'condition', ...
    'GroupingVariables', {'mouse','opsin'});

Twide.opsin = str2double(Twide.opsin);


% plot eOPN3 call rate
figure; 
subplot(121)
violinplot(Twide(Twide.opsin == 27, {'baseline', 'pulse_lightsoff', 'constant'}));
ylabel('calls / min')
x = ylim; 
subplot(122)
violinplot(Twide(isnan(Twide.opsin), {'baseline', 'pulse_lightsoff', 'constant'}));
ylim(x);


signrank( table2array(Twide(Twide.opsin == 27, {'baseline'})),  table2array(Twide(Twide.opsin == 27, {'constant'}))  )



