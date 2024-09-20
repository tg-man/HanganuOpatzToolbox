function [USVSDR, enoughUSV] = getUSVSDR(experiments, folder4USVpower, folder4USVSDR, params)

ch_acc = params.ch_acc;
ch_str = params.ch_str;
ch_th = params.ch_th;
minusvnum = params.minusvnum;  

for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    badch = rmmissing([experiment.NoisyCh experiment.OffCh]);   
    load([folder4USVpower experiment.animal_ID]);
    freqs = USVpower.freq; 
    % unpack and get rid of bad channels 
    during = USVpower.during; 
    during(badch, :, :) = NaN; 
    pre = USVpower.pre; 
    pre(badch, :, :) = NaN; 
    post = USVpower.post; 
    post(badch, :, :) = NaN; 

    % filter vector for if this animal vocalized enough 
    enoughUSV(exp_idx) = size(pre, 3) > minusvnum; 
    if size(pre, 3) > minusvnum     
        % calculate SDR call by call 
        for usv = 1 : size(pre, 3)
            if experiment.target2 == 1 % check targeting 
                SDRpre_accstr(usv, :) = getSDR(nanmedian(pre(ch_acc, :, usv), 1), nanmedian(pre(ch_str, :, usv), 1), freqs, []); 
                SDRduring_accstr(usv, :) = getSDR(nanmedian(during(ch_acc, :, usv), 1), nanmedian(during(ch_str, :, usv), 1), freqs, []); 
                SDRpost_accstr(usv, :) = getSDR(nanmedian(post(ch_acc, :, usv), 1), nanmedian(post(ch_str, :, usv), 1), freqs, []); 
            else
                SDRpre_accstr(usv, :) = NaN(1, 2); 
                SDRduring_accstr(usv, :) = NaN(1, 2); 
                SDRpost_accstr(usv, :) = NaN(1, 2); 
                
            end 
            if experiment.target3 == 1 % check targeting 
                SDRpre_accth(usv, :) = getSDR(nanmedian(pre(ch_acc, :, usv), 1), nanmedian(pre(ch_th, :, usv), 1), freqs, []); 
                SDRduring_accth(usv, :) = getSDR(nanmedian(during(ch_acc, :, usv), 1), nanmedian(during(ch_th, :, usv), 1), freqs, []); 
                SDRpost_accth(usv, :)  = getSDR(nanmedian(post(ch_acc, :, usv), 1), nanmedian(post(ch_th, :, usv), 1), freqs, []); 
            else 
                SDRpre_accth(usv, :) = NaN(1, 2); 
                SDRduring_accth(usv, :) = NaN(1, 2); 
                SDRpost_accth(usv, :)  = NaN(1, 2); 
            end 
        end 

        % put everything in a structure
        USVSDR.SDRpre_accstr = SDRpre_accstr; 
        USVSDR.SDRduring_accstr = SDRduring_accstr; 
        USVSDR.SDRpost_accstr = SDRpost_accstr; 
        USVSDR.SDRpre_accth = SDRpre_accth; 
        USVSDR.SDRduring_accth = SDRduring_accth;
        USVSDR.SDRpost_accth = SDRpost_accth;
        % save data
        if ~exist(folder4USVSDR, "dir")
            mkdir(folder4USVSDR)
        end 
        save([folder4USVSDR experiment.animal_ID], 'USVSDR');
        clear SDRpre_accstr SDRduring_accstr SDRpost_accstr SDRpre_accth SDRduring_accth SDRpost_accth

    end % if min usv check end     
end % exp loop end 
end % function end 