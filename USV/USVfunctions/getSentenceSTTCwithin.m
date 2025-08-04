function sentenceSTTC = getSentenceSTTCwithin(T, folder4SM, area, lags, repeat_calc, folder2save)
% Tony July 2025 

%  this script computes the STTC  value during relevant periods for USV sentences
%  1) baseline: 5 - 4s before a USV sentence 
%  2) prep: 1 - 0s before a USV sentence 
%  3) during: variable duration while USV lasts
% Input:
%     - T: table with all sentences from a particular animal, one sentence per row 
%     - folder4SM: folder to spike matrices 
%     - area: string of brain area to navigate to spike matrix file and saving at the end 
%     - lags: vector of lags in ms for STTC calculation 
%     - repeat_calc: 1 or 0, whether to overwrite previously exisiting output
%     - folder2save: folder where final output will be saved 
% 
% Output: 
%     - matlab structure with 

if repeat_calc == 0 && exist([folder2save area '\'  T.mouse{1}, '.mat']) 
    load([folder2save area '\'  T.mouse{1}, '.mat']); 
else 
    % get all experiments for later 
    experiments = get_experiment_redux;

    lags = lags ./ 1000; % convert to seconds from ms 

    % loop through each sentence for USV calculation 
    for sen_idx =  1 : size(T, 1)
        % select sentence 
        sentence = T(sen_idx, :); 

        % extract sentence time stamps 
        start = sentence.start; 
        stop = sentence.stop; 
   
        % find corresponding experiment 
        experiment = experiments(strcmp({experiments.USV}, sentence.usvfile));
    
        % load spike matrix
        load([folder4SM area '\' experiment.name]); 
        % in case spike matrix is too short (no spikes in the end) zero pad 
        if size(spike_matrix, 2) < stop
            spike_matrix(:, end: stop) = 0;
        end 
        % extract spikes during period of interest 
        spikes_baseline = spike_matrix(:, (start - 5000):(start - 4001)); 
        spikes_prep = spike_matrix(:, (start - 1000):(start - 1)); 
        spikes_during = spike_matrix(:, start:stop); 
        
        % compute STTC 
        for lag_idx = 1 : numel(lags)
            pair_idx = 1; % set counting pair index 
            for unit1 = 1 : numel(clusters)
                % baseline nums for STTC calculation 
                spikes1_baseline = find(spikes_baseline(unit1, :)) / 1000;
                num_spikes1_baseline = numel(spikes1_baseline);
                % prep nums for STTC calculation 
                spikes1_prep = find(spikes_prep(unit1, :)) / 1000;
                num_spikes1_prep = numel(spikes1_prep);
                % during nums for STTC calculation 
                spikes1_during = find(spikes_during(unit1, :)) / 1000;
                num_spikes1_during = numel(spikes1_during);

                for unit2 = unit1 + 1 : numel(clusters)
                    % baseline nums for STTC calculation 
                    spikes2_baseline = find(spikes_baseline(unit2, :)) / 1000;
                    num_spikes2_baseline = numel(spikes2_baseline);
                    % prep nums for STTC calculation 
                    spikes2_prep = find(spikes_prep(unit2, :)) / 1000;
                    num_spikes2_prep = numel(spikes2_prep);
                    % during nums for STTC calculation 
                    spikes2_during = find(spikes_during(unit2, :)) / 1000;
                    num_spikes2_during = numel(spikes2_during);

                    % baseline STTC calculation 
                    baseline(pair_idx, lag_idx, sen_idx) =  getSTTC(num_spikes1_baseline, num_spikes2_baseline, lags(lag_idx),...
                        [0 size(spikes_baseline, 2) / 1000], spikes1_baseline, spikes2_baseline);
                    % prep STTC calculation 
                    prep(pair_idx, lag_idx, sen_idx) =  getSTTC(num_spikes1_prep, num_spikes2_prep, lags(lag_idx),...
                        [0 size(spikes_prep, 2) / 1000], spikes1_prep, spikes2_prep);
                    % during STTC calculation 
                    during(pair_idx, lag_idx, sen_idx) =  getSTTC(num_spikes1_during, num_spikes2_during, lags(lag_idx),...
                        [0 size(spikes_during, 2) / 1000], spikes1_during, spikes2_during);
                    
                    pair_idx = pair_idx + 1;
                end % unit 2 loop end 
            end % unit 1 loop end 
        end % lag loop end 
    end % sentence loop end 

    % save output as a structure 
    sentenceSTTC.baseline = baseline; 
    sentenceSTTC.prep = prep; 
    sentenceSTTC.during = during; 
    sentenceSTTC.lags = lags; 
    sentenceSTTC.note = 'pairs x lags x trials'; 

    if ~exist([folder2save area])
        mkdir([folder2save area])
    end
    save([folder2save area '\'  experiment.animal_ID], 'sentenceSTTC'); 

end % repeat_cal check end 

end % function end 