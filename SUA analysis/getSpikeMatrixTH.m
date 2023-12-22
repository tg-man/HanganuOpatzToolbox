function [spike_matrix, clusters, SUAinfo] = ...
    getSpikeMatrixTH(experiment, resultsKlusta, save_data, repeatCalc, output_folder)
% by Mattia 07.20

% computes sparse spike_matrix starting from the output of sorted Klusta
% file. doesn't cuts periods of silence (> 500 ms of no spikes across all channels)

% input:  animal_name (string, also known as animal_ID)
%         resultsKlusta (string, folder in which you have SUA info files)
%         save_data (1 for yes)
%         repeatCalc (0 to load already computed stuff)
%         output_folder (string, where to save the spike matrix)
% output: spike_matrix (thought for computing xCorr)

animal_name = experiment.animal_ID;

if repeatCalc == 0 && exist(strcat(output_folder, experiment.name, '.mat'), 'file')
    load(strcat(output_folder, experiment.name, '.mat'))
else
    load(strcat(resultsKlusta, animal_name)) % load the saved SUA stuff
    for exp_idx = 1 : length(SUAinfo) % loop over recordings
        SUAstruct = SUAinfo{exp_idx};
        if size(SUAstruct, 2) >= 1 && strcmp(SUAstruct(1).file, experiment.name)
            if numel(fieldnames(SUAstruct)) > 0
                clusters = extractfield(SUAstruct, 'ClusterID'); % extract clusters
                for SUA = 1 : length(SUAstruct) % loop over single units
                    spike_times = ceil(SUAstruct(SUA).Timestamps / 32); % divided by 32 to get miliseconds; ceil to avoid having a spike time at 0. round to millisecond
                    spike_times = spike_times(spike_times > 0);
                    if ~ isnan(spike_times)
                        spike_matrix(SUAstruct(SUA).ClusterID == clusters, spike_times) = 1; % set to 1 if a spike is present in this millisecond
                    else
                        spike_matrix(SUAstruct(SUA).ClusterID == clusters, :) = 0;
                    end
                end
            end            
            break
        end
    end
    if exist('spike_matrix', 'var')
        spike_matrix = sparse(spike_matrix);
        % this is really the only different line from getSpikeMatrixHenrik
        spike_matrix = spike_matrix(~ismember([SUAstruct.channel], [experiment.OffCh experiment.NoisyCh] - 32), :); 
        clusters = clusters(~ismember([SUAstruct.channel], [experiment.OffCh experiment.NoisyCh] - 32)); 
    else
        spike_matrix = NaN;
        clusters = NaN;
        SUAinfo = NaN;
    end
    if save_data == 1
        if ~exist(output_folder)
            mkdir(output_folder)
        end 
        save(strcat(output_folder, experiment.name), 'spike_matrix', 'clusters')
    end
end
end