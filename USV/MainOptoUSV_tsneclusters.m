%% Looking at effect of opto on USV call type 
%% on a single ramp level 

% clear; 
% % get table with t-sne labels 
% T = readtable('Q:\Personal\Tony\Analysis\ephysUSVfeatures_pooled_tsne.csv', 'Delimiter', ',');
% 
% folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
% optostim = 'ACCdeep'; % ACCdeep   ACCsup
% 
% % get lists of experiments 
% experiments = get_experiment_redux;
% experiments = experiments(256:end);
% experiments = experiments([experiments.target2] == 1);
% experiments = experiments([experiments.DiI] == 0);
% for i = 1 : size(experiments, 2)
%     experiment = experiments(i); 
% %     if length(experiment.IUEconstruct) == 1 && experiment.IUEconstruct == 13
%     if length(experiment.IUEconstruct) == 1 && isnan(experiment.IUEconstruct)
%         opsin(i) = 1; 
%     else 
%         opsin(i) = 0; 
%     end 
% end 
% experiments = experiments(logical(opsin));
% experiments = experiments(strcmp({experiments.ramp}, optostim));
% 
% % initialize table
% OptoT = table('Size', [size(experiments, 2), 5], ... 
%     'VariableTypes', {'string', 'double', 'double', 'double', 'double',}, ... 
%     'VariableNames', {'mouse', 'p0', 'p1', 's0', 's1'});
% 
% % loop through experiment to populate table
% for exp_idx = 1 : size(experiments, 2)
%     experiment = experiments(exp_idx); 
%     T_exp = T(strcmp(T.file, experiment.USV), :);
% 
%     % get USV files and timestamps 
%     load([experiment.USV_path experiment.USV]); 
%     Calls = Calls(Calls.Accept, :);
%     % check labels and adjust timestamps 
%     if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
%         Calls.Box(:, 1) = Calls.Box(:, 1) - Calls.Box(1, 1); % adjust timestamps to align with ephys 
%         Calls(1, :) = []; % remove first timestamp, aritificially added start 
%         Calls(end, :) = []; % remove last timestemp, ariticially added end
%     else 
%         disp([experiment.USV ' wrongly labeled!!!'])
%     end 
%     
%     % check that both Calls and T_exp agree in size 
%     if size(T_exp, 1) == size(Calls, 1)
%         load([folder4stim experiment.name '_StimulationProperties_raw.mat']); 
%         ramps = strcmp(StimulationProperties_raw(:, 8), 'ramp');
%         StimulationProperties_raw = StimulationProperties_raw(ramps, :); 
%         stimtime = round(cell2mat(StimulationProperties_raw(:, 1:2)) / 3.2); % divided by 3.2 bc stim props are in 3.2k but usvs are in seconds 
%         % make aggregate timestamps for pre and stim 
%         stim = []; 
%         pre = []; 
%         for i = 1 : size(stimtime, 1)
%             pre = [pre, (stimtime(i, 1) - 3000):(stimtime(i, 1) - 1) ];
%             stim = [stim, stimtime(i, 1):stimtime(i, 2)]; 
%         end 
%         OptoT.p1(exp_idx) = sum(ismember(round(Calls.Box(:, 1)*1000), pre) & T_exp.tsne_label == 1);
%         OptoT.p0(exp_idx) = sum(ismember(round(Calls.Box(:, 1)*1000), pre) & T_exp.tsne_label == 0);
%         OptoT.s1(exp_idx) = sum(ismember(round(Calls.Box(:, 1)*1000), stim) & T_exp.tsne_label == 1);
%         OptoT.s0(exp_idx) = sum(ismember(round(Calls.Box(:, 1)*1000), stim) & T_exp.tsne_label == 0);
%         OptoT.mouse(exp_idx) = experiment.animal_ID; 
%     end 
%     clearvars Calls T_exp stimtime StimulationProperties_raw ramps
% end % mouse experiments end 
% 
% ptot = sum(OptoT.p0) + sum(OptoT.p1); 
% stot = sum(OptoT.s0) + sum(OptoT.s1);
% % bar plot with percentage 
% figure; 
% bardata = [sum(OptoT.p0)/ptot, sum(OptoT.p1)/ptot; sum(OptoT.s0)/stot, sum(OptoT.s1)/stot];
% bar(bardata,'stacked')
% xticklabels({'pre', 'stim'}); 
% ylabel('Fraction')
% title(optostim)
% legend('cluster 0', 'cluster 1')
% % bar plot with call number
% figure; 
% bardata = [sum(OptoT.p0), sum(OptoT.p1); sum(OptoT.s0), sum(OptoT.s1)];
% bar(bardata,'stacked')
% xticklabels({'pre', 'stim'}); 
% ylabel('# of calls')
% title(optostim)
% legend('cluster 0', 'cluster 1')

%% the entire ramp period 

clear; 
% get table with t-sne labels 
T = readtable('Q:\Personal\Tony\Analysis\ephysUSVfeatures_pooled_tsne.csv', 'Delimiter', ',');

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 

post = 3000; 

% get lists of experiments 
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);
for i = 1 : size(experiments, 2)
    experiment = experiments(i); 
    if length(experiment.IUEconstruct) == 1 && experiment.IUEconstruct == 13
%     if length(experiment.IUEconstruct) == 1 && isnan(experiment.IUEconstruct)
        opsin(i) = 1; 
    else 
        opsin(i) = 0; 
    end 
end 
experiments = experiments(logical(opsin));
experiments = experiments(strcmp({experiments.Exp_type}, 'baseline only') |   strcmp({experiments.ramp}, 'ACCsup')  | strcmp({experiments.ramp}, 'ACCdeep')) ; %
% get unique animal numbers
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

% initialize table
OptoT = table('Size', [size(animals, 2), 5], ... 
    'VariableTypes', {'string', 'double', 'double', 'double', 'double',}, ... 
    'VariableNames', {'mouse', 'b0', 'b1', 's0', 's1'});
OptoT{:, 2:5} = NaN; 

for animal_idx = 1 : size(animals, 2) 
    animal = animals{animal_idx}; 
    exp4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal));
    OptoT.mouse(animal_idx) = animal; 

    for exp_idx = 1 : size(exp4mouse, 2)
        experiment = exp4mouse(exp_idx);

        % put numbers in OptoT table based on experiment types 
        if strcmp(experiment.Exp_type, 'baseline only')
            % filter pooled USV table for tsne clusters
            T_exp = T(strcmp(T.file, experiment.USV), :);

            % populate the table 
            OptoT.b1(animal_idx) = sum(T_exp.tsne_label); 
            OptoT.b0(animal_idx) = size(T_exp, 1)- sum(T_exp.tsne_label);
            clearvars T_exp

        elseif strcmp(experiment.Exp_type, 'opto')
            % filter pooled USV table for tsne clusters
            T_exp = T(strcmp(T.file, experiment.USV), :);

            % get USV files and timestamps 
            load([experiment.USV_path experiment.USV]); 
            Calls = Calls(Calls.Accept, :);
            % check labels and adjust timestamps 
            if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
                Calls.Box(:, 1) = Calls.Box(:, 1) - Calls.Box(1, 1); % adjust timestamps to align with ephys 
                Calls(1, :) = []; % remove first timestamp, aritificially added start 
                Calls(end, :) = []; % remove last timestemp, ariticially added end
            else 
                disp([experiment.USV ' wrongly labeled!!!'])
            end 

            % get calls within ramp period, populate OptoT table
            if size(T_exp, 1) == size(Calls, 1)
                load([folder4stim experiment.name '_StimulationProperties_raw.mat']); 
                ramps = strcmp(StimulationProperties_raw(:, 8), 'ramp');
                StimulationProperties_raw = StimulationProperties_raw(ramps, :); 
                stim = round(cell2mat([StimulationProperties_raw(1, 1) StimulationProperties_raw(end ,2)]) / 3.2); % /3.2 bc stim prop is in 3.2k Hz 
                stim(end) = stim(end) + post; % add some post last ramp laser 
                % check calls in the period 
                if isnan(OptoT.s0(animal_idx))
                    temp = 0;
                else 
                    temp = OptoT.s0(animal_idx); 
                end 
                OptoT.s0(animal_idx) = temp + sum(ismember(round(Calls.Box(:, 1)*1000), stim(1):stim(end)) & (T_exp.tsne_label == 0)); % OptoT.s0(animal_idx) + 
                clear temp

                if isnan(OptoT.s1(animal_idx))
                    temp = 0; 
                else 
                    temp = OptoT.s1(animal_idx); 
                end 
                OptoT.s1(animal_idx) = temp + sum(ismember(round(Calls.Box(:, 1)*1000), stim(1):stim(end)) & (T_exp.tsne_label == 1)); % OptoT.s1(animal_idx) + 
                clear temp 
            end 
            clearvars T_exp Calls StimulationProperties_raw stim
        end 
    end % experiment loop end 
end % animal loop end 

btot = sum(rmmissing(OptoT.b0)) + sum(rmmissing(OptoT.b1)); 
stot = sum(rmmissing(OptoT.s0)) + sum(rmmissing(OptoT.s1));
% bar plot with percentage 
figure; 
bardata = [sum(rmmissing(OptoT.b0))/btot, sum(rmmissing(OptoT.b1))/btot; sum(rmmissing(OptoT.s0))/stot, sum(rmmissing(OptoT.s1))/stot];
bar(bardata,'stacked')
xticklabels({'Baseline', 'Stim'}); 
ylabel('Fraction')
title('Stim', 'FontWeight','normal')
legend('type 0', 'type 1')
set(gca, 'FontName', 'Arial', 'FontSize', 20, 'TickDir', 'out')

% bar plot with call number
figure; 
bardata = [sum(rmmissing(OptoT.b0)), sum(rmmissing(OptoT.b1)); sum(rmmissing(OptoT.s0)), sum(rmmissing(OptoT.s1))];
bar(bardata,'stacked')
xticklabels({'baseline', 'ramps'}); 
ylabel('# of calls')
title('sup & deep stim pooled')
legend('cluster 0', 'cluster 1')




% 
% % save the OptoT for stats later 
% OptoT.pb0 = OptoT.b0 ./ (OptoT.b0 + OptoT.b1); 
% OptoT.pb1 = OptoT.b1 ./ (OptoT.b0 + OptoT.b1); 
% OptoT.ps0 = OptoT.s0 ./ (OptoT.s0 + OptoT.s1); 
% OptoT.ps1 = OptoT.s1 ./ (OptoT.s0 + OptoT.s1); 
% % save 
% % writetable(OptoT, 'C:\Users\tman\Desktop\OptoUSVcalltypes.csv', 'QuoteStrings', true);
% 
% tt = OptoT(:, 1:5); 
% unstack(tt, {'b0', 'b1', 's0', 's1'})



%% generate long format table  

clear
% get table with t-sne labels 
T = readtable('Q:\Personal\Tony\Analysis\USV_csvs\ephysUSVfeatures_pooled_tsne.csv', 'Delimiter', ',');

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 

post = 3000; 

% get lists of experiments 
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);
for i = 1 : size(experiments, 2)
    experiment = experiments(i); 
    if length(experiment.IUEconstruct) == 1 && experiment.IUEconstruct == 13  % switch if statement here to filter different experiments 
%     if length(experiment.IUEconstruct) == 1 && isnan(experiment.IUEconstruct)  % switch if statement here to filter different experiments 
        opsin(i) = 1; 
    else 
        opsin(i) = 0; 
    end 
end 
experiments = experiments(logical(opsin));
experiments = experiments(strcmp({experiments.Exp_type}, 'baseline only') |  strcmp({experiments.ramp}, 'ACCsup') | strcmp({experiments.ramp}, 'ACCdeep') ) ; % 

% get unique animal numbers
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

% initialize table
OptoT = table('Size', [size(animals, 2)*2, 4], ... 
    'VariableTypes', {'string', 'double', 'double', 'double'}, ... 
    'VariableNames', {'mouse', 'condition', 'type0', 'type1'});
OptoT{:, 3:4} = NaN; 
OptoT.mouse = reshape(repmat(animals, [2, 1]), [], 1);
if experiments(1).IUEconstruct == 13 
    stimcon = 1; 
    con = 'stim'; 
elseif isnan(experiments(1).IUEconstruct)
    stimcon = 2; 
    con = 'ctrl'; 
end 
OptoT.condition = repmat([0; stimcon], [size(animals, 2), 1]);

% loop through table rows 
for idx = 1 : size(OptoT, 1)

    animal = OptoT.mouse(idx); 
    exp4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal));

    % filter experiments for row 
    if OptoT.condition(idx) == 0
        exp4row = exp4mouse(strcmp(extractfield(exp4mouse, 'Exp_type'), 'baseline only'));
    elseif ~OptoT.condition(idx) == 0
        exp4row = exp4mouse(strcmp(extractfield(exp4mouse, 'Exp_type'), 'opto'));
    end 

    % loop through experiments 
    for exp_idx = 1 : size(exp4row, 2)

        experiment = exp4row(exp_idx);

        % put numbers in OptoT table based on experiment types 
        if strcmp(experiment.Exp_type, 'baseline only')
            % filter pooled USV table for tsne clusters
            T_exp = T(strcmp(T.file, experiment.USV), :);

            % populate the table 
            OptoT.type0(idx) = size(T_exp, 1)- sum(T_exp.tsne_label);
            OptoT.type1(idx) = sum(T_exp.tsne_label); 
            clearvars T_exp

        elseif strcmp(experiment.Exp_type, 'opto')
            % filter pooled USV table for tsne clusters
            T_exp = T(strcmp(T.file, experiment.USV), :);

            % get USV files and timestamps 
            load([experiment.USV_path experiment.USV]); 
            Calls = Calls(Calls.Accept, :);
            % check labels and adjust timestamps 
            if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
                Calls.Box(:, 1) = Calls.Box(:, 1) - Calls.Box(1, 1); % adjust timestamps to align with ephys 
                Calls(1, :) = []; % remove first timestamp, aritificially added start 
                Calls(end, :) = []; % remove last timestemp, ariticially added end
            else 
                disp([experiment.USV ' wrongly labeled!!!'])
            end 

            % get calls within ramp period, populate OptoT table
            if size(T_exp, 1) == size(Calls, 1)
                load([folder4stim experiment.name '_StimulationProperties_raw.mat']); 
                ramps = strcmp(StimulationProperties_raw(:, 8), 'ramp');
                StimulationProperties_raw = StimulationProperties_raw(ramps, :); 
                stim = round(cell2mat([StimulationProperties_raw(1, 1) StimulationProperties_raw(end ,2)]) / 3.2); 
                stim(end) = stim(end) + post; % add some post last ramp laser 
                % check calls in the period 
                if isnan(OptoT.type0(idx))
                    temp = 0;
                else 
                    temp = OptoT.type0(idx); 
                end 
                OptoT.type0(idx) = temp + sum(ismember(round(Calls.Box(:, 1)*1000), stim(1):stim(end)) & (T_exp.tsne_label == 0)); 
                clear temp

                if isnan(OptoT.type1(idx))
                    temp = 0; 
                else 
                    temp = OptoT.type1(idx); 
                end 
                OptoT.type1(idx) = temp + sum(ismember(round(Calls.Box(:, 1)*1000), stim(1):stim(end)) & (T_exp.tsne_label == 1)); 
                clear temp 
            end 
            clearvars T_exp Calls StimulationProperties_raw stim
        end 
    end % experiment loop end 
end 

% save 
OptoT.frac_0 = OptoT.type0 ./ (OptoT.type0 + OptoT.type1);
OptoT.frac_1 = OptoT.type1 ./ (OptoT.type0 + OptoT.type1);
writetable(OptoT, ['Q:\Personal\Tony\Analysis\USV_csvs\rampUSVcalltypes_' con '.csv'], 'QuoteStrings', true);









