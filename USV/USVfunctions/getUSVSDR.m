function [animals] = getUSVSDR(experiments, folder4USVpower, folder4USVSDR, params)

% unpack params 
ch_acc = params.ch_acc;
ch_str = params.ch_str;
ch_th = params.ch_th;

% unique animals 
animals = unique({experiments.animal_ID}); 

for mouse_idx = 1 : numel(animals)
    mouse = animals{mouse_idx}; 
    experiment = experiments(strcmp({experiments.animal_ID}, mouse)); 

    % load power spectra 
    load([folder4USVpower mouse]);

    % extract bad channnels
    badch = rmmissing([experiment(1).NoisyCh experiment(1).OffCh]);
    
    % unpack power spectra and get rid of bad channels 
    baseline = USVpower.baseline; 
    baseline(badch, :, :) = NaN;
    prep = USVpower.prep; 
    prep(badch, :, :) = NaN;  
    during = USVpower.during; 
    during(badch, :, :) = NaN; 

    freqs = USVpower.freq; 

    % calculate SDR sentence by sentence 
    for usv = 1 : size(prep, 3) 
        % acc str 
        if experiment(1).target2 == 1 
            SDRbaseline_accstr(usv, :) = getSDR(nanmedian(baseline(ch_acc, :, usv), 1), nanmedian(baseline(ch_str, :, usv), 1), freqs, []);
            SDRprep_accstr(usv, :) = getSDR(nanmedian(prep(ch_acc, :, usv), 1), nanmedian(prep(ch_str, :, usv), 1), freqs, []);
            SDRduring_accstr(usv, :) = getSDR(nanmedian(during(ch_acc, :, usv), 1), nanmedian(during(ch_str, :, usv), 1), freqs, []);
        else 
            SDRbaseline_accstr(usv, :) = NaN(1, 2);
            SDRprep_accstr(usv, :) = NaN(1, 2);
            SDRduring_accstr(usv, :) = NaN(1, 2);
        end 

        % acc th 
        if experiment(1).target3 == 1 
            SDRbaseline_accth(usv, :) = getSDR(nanmedian(baseline(ch_acc, :, usv), 1), nanmedian(baseline(ch_th, :, usv), 1), freqs, []);
            SDRprep_accth(usv, :) = getSDR(nanmedian(prep(ch_acc, :, usv), 1), nanmedian(prep(ch_th, :, usv), 1), freqs, []);
            SDRduring_accth(usv, :) = getSDR(nanmedian(during(ch_acc, :, usv), 1), nanmedian(during(ch_th, :, usv), 1), freqs, []);
        else 
            SDRbaseline_accth(usv, :) = NaN(1, 2);
            SDRprep_accth(usv, :) = NaN(1, 2);
            SDRduring_accth(usv, :) = NaN(1, 2);
        end 
    end 

    % put everything in a structure
    USVSDR.SDRbaseline_accstr = SDRbaseline_accstr; 
    USVSDR.SDRprep_accstr = SDRprep_accstr; 
    USVSDR.SDRduring_accstr = SDRduring_accstr; 
    USVSDR.SDRbaseline_accth = SDRbaseline_accth; 
    USVSDR.SDRprep_accth = SDRprep_accth; 
    USVSDR.SDRduring_accth = SDRduring_accth;
    
    % save data
    if ~exist(folder4USVSDR, "dir")
        mkdir(folder4USVSDR)
    end 
    save([folder4USVSDR mouse], 'USVSDR');
    clearvars baseline prep during SDRbaseline_accstr SDRprep_accstr SDRduring_accstr SDRbaseline_accth SDRprep_accth SDRduring_accth

end % mouse loop end 

end % function end 