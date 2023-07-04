function gPDC_ramp = getRampGPDC(experiment, signal_1, signal_2, fs, high_cut, folder4stim,  repeatCalc, save_data, result_path)
% by Tony to calculate gPDC of ramp stimulation 
% inputs: 
%     - experiment: your excel 
%     - signal_1&2: signals at 1000Hz
%     - fs: that of the signal 
%     - high_cut: frequency high cut 
%     - folder4stim: your stimulation properties 
%     - save_data: 1 = save;0 = don't save; 
%     - result_parth: where to save the gPDC ramp results 

if repeatCalc == 0 && exist([result_path experiment.name '_gPDC_ramp.mat'], 'file')
    load([result_path experiment.name '_gPDC_ramp.mat']); 
else 
    % set some params for PDC computation 
    window_length = 1; % in seconds
    nFreqs = 512; % number of frequency bins 
    lenWind = window_length * fs; % window length, from seconds to frames 
    numWind = floor((2*3*fs)/lenWind) - 1; % number of total windows with 50% overlap each sliding step
    f = fs/(2*nFreqs):fs/(2*nFreqs):high_cut; % frequency vectors 

    % de-noise parameters 
    N = 4; 
    wname='db4';

    % PDC_computation parameters 
    metric = 'diag';
    maxIP = 50;
    alg = 1;
    criterion = 1;
    flag_mvarresidue = 1;
    alpha = 0; 

    % initialize gPDC matrices
    cp12 = []; cp21 = [];
    cs12 = []; cs21 = [];

    % load stim props and only get the ramp ones    
    load([folder4stim experiment.name '_StimulationProperties_raw.mat'])
    StimulationProperties_raw = StimulationProperties_raw(strcmp(StimulationProperties_raw(:,8), 'ramp'), :); 
    StimulationProperties_raw = StimulationProperties_raw(round(cell2mat(StimulationProperties_raw(:, 5))) == 3, :); 

    % extract timestamps and convert to ms 
    stim_start = ceil(cell2mat(StimulationProperties_raw(:,1)) ./ 3.2);
    stim_end = floor(cell2mat(StimulationProperties_raw(:,2)) ./ 3.2);

    % loop of ramps: 
    for ramp = 1: numel(stim_start) 
        % cut signal for this iteration using timestamps 
        seg1_pre = signal_1(stim_start(ramp) - 3005 : stim_start(ramp)); 
        seg2_pre = signal_2(stim_start(ramp) - 3005 : stim_start(ramp)); 
        seg1_stim = signal_1(stim_start(ramp) + 1000 : stim_end(ramp) + 1000); % shift by 1 second, + 1000 
        seg2_stim = signal_2(stim_start(ramp) + 1000 : stim_end(ramp) + 1000); 
        
        for num = 1:numWind
            S = (num-1)*lenWind/2+1;
            E = (num+1)*lenWind/2;   
            xp = detrend(seg1_pre(S:E));
            yp = detrend(seg2_pre(S:E));
            xs = detrend(seg1_stim(S:E));
            ys = detrend(seg2_stim(S:E));
    
            % de-noise and reconstruct a new signal with less noise  
            [THR,SORH,KEEPAPP] = ddencmp('den','wp',xp); 
            xp = wdencmp('gbl',xp, wname,N,THR,SORH,KEEPAPP);
            [THR,SORH,KEEPAPP] = ddencmp('den','wp',xs); 
            xs = wdencmp('gbl',xs, wname,N,THR,SORH,KEEPAPP) ;  
            [THR,SORH,KEEPAPP] = ddencmp('den','wp',yp);
            yp = wdencmp('gbl',yp, wname,N,THR,SORH,KEEPAPP);
            [THR,SORH,KEEPAPP] = ddencmp('den','wp',ys);
            ys = wdencmp('gbl',ys, wname,N,THR,SORH,KEEPAPP);

            up = [xp' yp']; % put signal into one matrix as required for the next function 
            us = [xs' ys']; 
            
            cp = PDC_computation(up, nFreqs, metric, maxIP, alg, alpha, criterion, flag_mvarresidue); 
            cs = PDC_computation(us, nFreqs, metric, maxIP, alg, alpha, criterion, flag_mvarresidue); 
            
            if ~isempty(cp) % input the values into gPDC matrix with each loop/window 
                cp12=[cp12, cp.c12];
                cp21=[cp21, cp.c21];
            else 
                cp12=[cp12, NaN(nFreqs, 1)]; 
                cp21=[cp21, NaN(nFreqs, 1)];
            end 
            if ~isempty(cs) 
                cs12=[cs12, cs.c12];
                cs21=[cs21, cs.c21];
            else 
                cs12=[cs12, NaN(nFreqs, 1)]; 
                cs21=[cs21, NaN(nFreqs, 1)];
            end
        end % window loop end 
        
        % take the median of all windows (over the entire signal duration)
        pre12(:, ramp) = nanmedian(cp12,2); 
        pre21(:, ramp) = nanmedian(cp21,2); 
        stim12(:, ramp) = nanmedian(cs12, 2); 
        stim21(:, ramp) = nanmedian(cs21, 2); 

    end % ramp loop end  
    
    % put everything in a structure 
    gPDC_ramp.pre12 = pre12; 
    gPDC_ramp.pre21 = pre21; 
    gPDC_ramp.stim12 = stim12; 
    gPDC_ramp.stim21 = stim21;
    gPDC_ramp.f = f;
    gPDC_ramp.len_win = window_length; 
    gPDC_ramp.fs = fs;
    gPDC_ramp.Note = 'c12: 2 driving 1; c21: 1 driving 2'; 
    
    if save_data == 1 
        if ~exist([result_path], 'dir')
            mkdir([result_path]); 
        end 
        save([result_path experiment.name '_gPDC_ramp'], 'gPDC_ramp');
    else 
        disp(['Data NOT saved for ' experiment.name '!!!'])
    end 
    
end % initial if statement end 
end % function end 