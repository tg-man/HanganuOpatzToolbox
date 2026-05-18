function [animals] = getUSVSDR_2phases(experiments, folder4USVpower, folder4USVSDR, params)

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
    peri = USVpower.peri; 
    peri(badch, :, :) = NaN;  

    freqs = USVpower.freq; 

    % calculate SDR sentence by sentence 
    for usv = 1 : size(peri, 3) 
        % acc str 
        if experiment(1).target2 == 1 
            SDRbaseline_accstr(usv, :) = getSDR(nanmedian(baseline(ch_acc, :, usv), 1), nanmedian(baseline(ch_str, :, usv), 1), freqs, []);
            SDRperi_accstr(usv, :) = getSDR(nanmedian(peri(ch_acc, :, usv), 1), nanmedian(peri(ch_str, :, usv), 1), freqs, []);
        else 
            SDRbaseline_accstr(usv, :) = NaN(1, 2);
            SDRperi_accstr(usv, :) = NaN(1, 2);
        end 

        % acc th 
        if experiment(1).target3 == 1 
            SDRbaseline_accth(usv, :) = getSDR(nanmedian(baseline(ch_acc, :, usv), 1), nanmedian(baseline(ch_th, :, usv), 1), freqs, []);
            SDRperi_accth(usv, :) = getSDR(nanmedian(peri(ch_acc, :, usv), 1), nanmedian(peri(ch_th, :, usv), 1), freqs, []);
        else 
            SDRbaseline_accth(usv, :) = NaN(1, 2);
            SDRperi_accth(usv, :) = NaN(1, 2);
        end 
    end 

    % put everything in a structure
    USVSDR.SDRbaseline_accstr = SDRbaseline_accstr; 
    USVSDR.SDRperi_accstr = SDRperi_accstr; 
    USVSDR.SDRbaseline_accth = SDRbaseline_accth; 
    USVSDR.SDRperi_accth = SDRperi_accth; 
    
    % save data
    if ~exist(folder4USVSDR, "dir")
        mkdir(folder4USVSDR)
    end 
    save([folder4USVSDR mouse], 'USVSDR');
    clearvars baseline peri SDRbaseline_accstr SDRperi_accstr SDRbaseline_accth SDRperi_accth

end % mouse loop end 

end % function end 