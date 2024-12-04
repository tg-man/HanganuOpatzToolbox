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
    pre3 = USVpower.pre3; 
    pre3(badch, :, :) = NaN;
    pre5 = USVpower.pre5; 
    pre5(badch, :, :) = NaN;
    post = USVpower.post; 
    post(badch, :, :) = NaN; 

    % filter vector for if this animal vocalized enough 
    enoughUSV(exp_idx) = size(pre, 3) > minusvnum; 
    if size(pre, 3) > minusvnum     
        % calculate SDR call by call 
        for usv = 1 : size(pre, 3)
            if experiment.target2 == 1 % check targeting 
                SDRpre5_accstr(usv, :) = getSDR(nanmedian(pre5(ch_acc, :, usv), 1), nanmedian(pre5(ch_str, :, usv), 1), freqs, []); 
                SDRpre3_accstr(usv, :) = getSDR(nanmedian(pre3(ch_acc, :, usv), 1), nanmedian(pre3(ch_str, :, usv), 1), freqs, []); 
                SDRpre_accstr(usv, :) = getSDR(nanmedian(pre(ch_acc, :, usv), 1), nanmedian(pre(ch_str, :, usv), 1), freqs, []); 
                SDRduring_accstr(usv, :) = getSDR(nanmedian(during(ch_acc, :, usv), 1), nanmedian(during(ch_str, :, usv), 1), freqs, []); 
                SDRpost_accstr(usv, :) = getSDR(nanmedian(post(ch_acc, :, usv), 1), nanmedian(post(ch_str, :, usv), 1), freqs, []); 
            else
                SDRpre5_accstr(usv, :) = NaN(1, 2); 
                SDRpre3_accstr(usv, :) = NaN(1, 2); 
                SDRpre_accstr(usv, :) = NaN(1, 2); 
                SDRduring_accstr(usv, :) = NaN(1, 2); 
                SDRpost_accstr(usv, :) = NaN(1, 2); 
                
            end 
            if experiment.target3 == 1 % check targeting 
                SDRpre5_accth(usv, :) = getSDR(nanmedian(pre5(ch_acc, :, usv), 1), nanmedian(pre5(ch_th, :, usv), 1), freqs, []);
                SDRpre3_accth(usv, :) = getSDR(nanmedian(pre3(ch_acc, :, usv), 1), nanmedian(pre3(ch_th, :, usv), 1), freqs, []);
                SDRpre_accth(usv, :) = getSDR(nanmedian(pre(ch_acc, :, usv), 1), nanmedian(pre(ch_th, :, usv), 1), freqs, []); 
                SDRduring_accth(usv, :) = getSDR(nanmedian(during(ch_acc, :, usv), 1), nanmedian(during(ch_th, :, usv), 1), freqs, []); 
                SDRpost_accth(usv, :)  = getSDR(nanmedian(post(ch_acc, :, usv), 1), nanmedian(post(ch_th, :, usv), 1), freqs, []); 
            else 
                SDRpre5_accth(usv, :) = NaN(1, 2); 
                SDRpre3_accth(usv, :) = NaN(1, 2); 
                SDRpre_accth(usv, :) = NaN(1, 2); 
                SDRduring_accth(usv, :) = NaN(1, 2); 
                SDRpost_accth(usv, :)  = NaN(1, 2); 
            end 
        end 

        % put everything in a structure
        USVSDR.SDRpre5_accstr = SDRpre5_accstr; 
        USVSDR.SDRpre3_accstr = SDRpre3_accstr; 
        USVSDR.SDRpre_accstr = SDRpre_accstr; 
        USVSDR.SDRduring_accstr = SDRduring_accstr; 
        USVSDR.SDRpost_accstr = SDRpost_accstr; 
        USVSDR.SDRpre5_accth = SDRpre5_accth; 
        USVSDR.SDRpre3_accth = SDRpre3_accth; 
        USVSDR.SDRpre_accth = SDRpre_accth; 
        USVSDR.SDRduring_accth = SDRduring_accth;
        USVSDR.SDRpost_accth = SDRpost_accth;
        % save data
        if ~exist(folder4USVSDR, "dir")
            mkdir(folder4USVSDR)
        end 
        save([folder4USVSDR experiment.animal_ID], 'USVSDR');
        clear SDRpre_accstr SDRduring_accstr SDRpost_accstr SDRpre3_accstr SDRpre5_accstr SDRpre3_accth SDRpre5_accth SDRpre_accth SDRduring_accth SDRpost_accth

    end % if min usv check end     
end % exp loop end 
end % function end 