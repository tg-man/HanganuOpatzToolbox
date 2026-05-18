function sentenceSTTC = getSentenceSTTCx_2phases(T, folder4SM, area1, area2, lags, repeat_calc, folder2save)
% Tony July 2025 

%  this script computes the STTC  value during relevant periods for USV sentences
%  1) baseline: 5 - 4s before a USV sentence 
%  2) peri: -0.5 - 0.5s around a USV sentence 
%  
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

if repeat_calc == 0 && exist([folder2save area1 area2 '\'  T.mouse{1}, '.mat']) 
    load([folder2save area1 area2 '\'  T.mouse{1}, '.mat']); 
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
    
        % load spike matrix area 1 
        load([folder4SM area1 '\' experiment.name]); 
        % in case spike matrix is too short (no spikes in the end) zero pad 
        if size(spike_matrix, 2) < stop
            spike_matrix(:, end: stop) = 0;
        end 
        % extract spikes during period of interest 
        sm1_baseline = spike_matrix(:, (start - 5000):(start - 4001)); 
        sm1_peri = spike_matrix(:, (start - 700):(start + 299)); 
        clusters1 = clusters; 
        clearvars spike_matrix clusters

        % load spike matrix area 2
        load([folder4SM area2 '\' experiment.name]); 
        % in case spike matrix is too short (no spikes in the end) zero pad 
        if size(spike_matrix, 2) < stop
            spike_matrix(:, end: stop) = 0;
        end 
        % extract spikes during period of interest 
        sm2_baseline = spike_matrix(:, (start - 5000):(start - 4001)); 
        sm2_peri = spike_matrix(:, (start - 700):(start + 299)); 
        clusters2 = clusters; 
        clearvars spike_matrix clusters

        % compute STTC 
        for lag_idx = 1 : numel(lags)
            pair_idx = 1; % set counting pair index 
            for unit1 = 1 : numel(clusters1)
                % baseline nums for STTC calculation 
                spikes1_baseline = find(sm1_baseline(unit1, :)) / 1000;
                num_spikes1_baseline = numel(spikes1_baseline);
                % peri nums for STTC calculation 
                spikes1_peri = find(sm1_peri(unit1, :)) / 1000;
                num_spikes1_peri = numel(spikes1_peri);

                for unit2 = 1 : numel(clusters2)
                    % baseline nums for STTC calculation 
                    spikes2_baseline = find(sm2_baseline(unit2, :)) / 1000;
                    num_spikes2_baseline = numel(spikes2_baseline);
                    % prep nums for STTC calculation 
                    spikes2_peri = find(sm2_peri(unit2, :)) / 1000;
                    num_spikes2_peri = numel(spikes2_peri);

                    % baseline STTC calculation 
                    baseline(pair_idx, lag_idx, sen_idx) =  getSTTC(num_spikes1_baseline, num_spikes2_baseline, lags(lag_idx),...
                        [0 size(sm1_baseline, 2) / 1000], spikes1_baseline, spikes2_baseline);
                    % peri STTC calculation 
                    peri(pair_idx, lag_idx, sen_idx) =  getSTTC(num_spikes1_peri, num_spikes2_peri, lags(lag_idx),...
                        [0 size(sm1_peri, 2) / 1000], spikes1_peri, spikes2_peri);
                    
                    pair_idx = pair_idx + 1;
                end % unit 2 loop end 
            end % unit 1 loop end 
        end % lag loop end 
    end % sentence loop end 

    % save output as a structure 
    sentenceSTTC.baseline = baseline; 
    sentenceSTTC.peri = peri; 
    sentenceSTTC.lags = lags; 
    sentenceSTTC.note = 'pairs x lags x trials'; 

    if ~exist([folder2save area1 area2])
        mkdir([folder2save area1 area2])
    end
    save([folder2save area1 area2 '\'  experiment.animal_ID], 'sentenceSTTC'); 

end % repeat_cal check end 

end % function end 