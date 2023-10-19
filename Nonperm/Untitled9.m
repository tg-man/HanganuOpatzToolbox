%% look at wave form similarities and channel numbers 

clear
experiments = get_experiment_redux; 
experiments = experiments([74:175]); % 177 180 185

area = 'Str'; % {'ACC', 'PFC', 'PL', 'Str', 'TH3'} 
experiments = experiments(extractfield(experiments, 'target2') == 1);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 87);
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'NaN'));
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));

folder4suainfo = 'Q:\Personal\Tony\Analysis\Results_3Probe_SUAinfo\'; 
folder4optomatrices = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesRamp_shift\'; 

offrampcut = 0.2; 

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx);
    
    % load ramp matrix
    load([folder4optomatrices area filesep experiment.name '.mat'])
    matrix = squeeze(sum(SUAdata_ramp.ramp_spike_matrix, 1)); 
    
    % load SUAinfo and extract infos. Spike matrices and SUAinfo have matching order so unit ID isn't messed up    
    load([folder4suainfo area filesep experiment.animal_ID])
    for j = 1 : size(SUAinfo, 2)
        if strcmp(SUAinfo{1,j}(1).file, experiment.name)
            SUAstruct = SUAinfo{1,j};
            if size(matrix,1) == size(SUAstruct, 2)
                channels = extractfield(SUAstruct, 'channel');
                waveforms = {SUAstruct.Waveform};
                
                during = squeeze(sum(matrix(:, 3001:6000), 2)); 
                post = squeeze(sum(matrix(:, 6001:9000), 2)); 
                offramp = post > during.*(1 + offrampcut); 
                
                % plot channel distribution 
                figure;
                subplot(121); histogram(channels); title('all units'); xlabel('channel'); a = ylim; 
                subplot(122); histogram(channels(offramp)); title('off ramp'); xlabel('channel'); ylim(a);
                sgtitle(experiment.animal_ID); 
                
                % compute and plot pairwise waveform similarities 
                waveforms = reshape(waveforms, 1, []);
                wfrep = repmat(waveforms, length(waveforms), 1);
                similarities = triu(cellfun(@getCosSim, wfrep, wfrep'),1);
                similarities_off = similarities(offramp, offramp);
                similarities = nonzeros(similarities);
                similarities_off = nonzeros(similarities_off);
                
                figure; 
                violinplot([similarities; similarities_off], [ones(length(similarities),1); 2*ones(length(similarities_off),1)]); 
                xticklabels({'all units', 'off-ramp units'}); ylabel('pairwise cosine similarities'); 
                ylim([0.5 1.05])
%                 text(1.35, 0.85, ['p = ' num2str(ranksum(similarities, similarities_off))]);
                title(experiment.animal_ID)         
            end 
        end
    end 
    
end 
