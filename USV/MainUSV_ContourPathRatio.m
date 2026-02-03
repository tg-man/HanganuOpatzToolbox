%% Contour path ratio
% contour skeleton length divided by the box diagonal 
% * diagonal length is only taken for the actual vocalizing time 
% * if the call has a time break, the box diagonal is shortened accordingly
% 
% this use an contour detection that's also written in a separate script. 
% Some excess part of the original script is trimmed here for simplicity. 
% Order of code differ. Some lines are taken out of the loop to run once. 
% 
% Input: 
% 
% Output: 
% 

clear

% get experiments
experiments = get_experiment_redux;
experiments = experiments(256:506);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);

% whether to overwrite existing data 
repeat_calc = 0; 
% path to save 
folder2save = 'Q:\Personal\Tony\Analysis\Results_USV\PathRatio\'; 

% detection parameters 
threshold_abs = -100; % prctile(background(:), 90); % in dB 
threshold_rel = 1.5; 
% lowering step 
step_abs = 5; 
step_rel = 0.1; 
% gaussian kernel
smoothing = fspecial('gaussian', [5 5], 0.9); 
% spectrogram params
windowLength = 1000;             % Window length in samples (4 ms)
window = hamming(windowLength);  % Hamming window
noverlap = windowLength / 2;     % 50% overlap
nfft = 1024;                     % Number of FFT points

% loop through experiments
for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    if repeat_calc == 0 && exist([folder2save experiment.USV '.csv'], 'file')
        readtable([folder2save experiment.USV '.csv']); 
        disp(['skipping experiment ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
    else 
        % load call file
        load([experiment.USV_path experiment.USV '.mat'])
        % filter only accepted calls 
        Calls = Calls(Calls.Accept, :); 
        Calls.Box(:, 2) = Calls.Box(:, 2)*1000; % from kHz to Hz 
        Calls.Box(:, 4) = Calls.Box(:, 4)*1000; % from kHz to Hz 
    
        if size(Calls, 1) > 2 % check if the animal vocalized at all  
            disp(['running experiment ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
            % get spectrogram of audio file
            [~, F, T, P] = spectrogram(audioread(audiodata.Filename), window, noverlap, nfft, audiodata.SampleRate, 'yaxis');
            
            % take the zscore of P for relative spectrogram 
            P_rel = zscore(10*log10(P), [], 2);
            
            % initialize animal table 
            df_mouse = []; 
            % loop through each calls to save a fig of just the one call
            for j = 2 : (size(Calls, 1) - 1) % first and last call aren't calls, but artificial markers 
            
                % find the index in the time vector for this call
                idx_xmin = find(T > (Calls.Box(j,1) - 0.08), 1); 
                idx_xmax = find(T > (Calls.Box(j,1) + Calls.Box(j,3) + 0.08), 1);
                % in case this call is very close to the beginning 
                if isempty(idx_xmin)
                    idx_xmin = 1; 
                end 
                % in case this call is very close to the end 
                if isempty(idx_xmax) 
                    idx_xmax = size(T, 2); 
                end 

%                 % create the figure
%                 figure;
%                 subplot(121);
%                 imagesc(T(idx_xmin:idx_xmax), F, 10*log10(P(:, idx_xmin:idx_xmax)));
%                 axis xy;
%                 xlabel('Time (s)');
%                 ylabel('Frequency (Hz)');
%                 colormap inferno;
%                 colorbar;
%                 clim([-115 -73]);
%                 set(gca, 'TickDir', 'out')
%                 title(j)
%                 % add a box
%                 rectangle('Position', Calls.Box(j, :),'EdgeColor' , 'g');
            
                % absolute thresholding 
                C_abs = conv2(10*log10(P(:, idx_xmin:idx_xmax)), smoothing, 'same') > threshold_abs; 
                % relative thresholding 
                C_rel = conv2(P_rel(:, idx_xmin:idx_xmax), smoothing, 'same') > threshold_rel; 
            
                % get initial contour 
                contour = C_rel & C_abs;
            
                % get rid of area outside of the box
                % find box stamps 
                start = find(T(idx_xmin:idx_xmax) > Calls.Box(j,1), 1);
                stop = find(T(idx_xmin:idx_xmax) > (Calls.Box(j,1) + Calls.Box(j,3)), 1);
                top = find(F > (Calls.Box(j, 2) + Calls.Box(j, 4)), 1); 
                bottom = find(F > Calls.Box(j, 2), 1);
                % correct case where top is too high 
                if isempty(top)
                    top = length(F); 
                end 
                % clear area outside of box 
                contour(1:bottom, :) = 0; 
                contour(top:end, :) = 0; 
                contour(:, 1:start) = 0; 
                contour(:, stop:end) = 0;
    
                % in case no contour detected, lower threshold and redetect 
                lowering = 1;
                while ~any(any(contour))
                    % absolute thresholding 
                    C_abs = conv2(10*log10(P(:, idx_xmin:idx_xmax)), smoothing, 'same') > (threshold_abs - lowering * step_abs); 
                    % relative thresholding 
                    C_rel = conv2(P_rel(:, idx_xmin:idx_xmax), smoothing, 'same') > (threshold_rel - lowering * step_rel); 
                    % get initial contour 
                    contour = C_rel & C_abs;
                    % clear area outside of box 
                    contour(1:bottom, :) = 0; 
                    contour(top:end, :) = 0; 
                    contour(:, 1:start) = 0; 
                    contour(:, stop:end) = 0;
                    % update counting variable
                    lowering = lowering + 1; 
                end 
    
                % connect sparse dots; leave thick contours alone
                % get skeleton of the contour
                skeleton = bwmorph(contour, 'skel', Inf); 
                % dilate the skeleton
                se = strel('rectangle', [12, 4]);
                skeleton = imdilate(skeleton, se);
                % thin it back down 
                skeleton = bwmorph(skeleton, 'thin', 3);
                % union with original thresholded contour
                contour = contour | skeleton; 
            
                % connected close by objects
                se = strel('rectangle', [20, 4]);  % spatial element 
                contour = imclose(contour, se);
                % bridge 1 pixel gaps - but repeat 10 times
                contour = bwmorph(contour, 'bridge', 10);
    
                % clear area outside of box again
                contour(1:bottom, :) = 0; 
                contour(top:end, :) = 0; 
                contour(:, 1:start) = 0; 
                contour(:, stop:end) = 0;
    
                % get contour skeleton and its length 
                [skel, skelLength] = getContourSkeletonLength(contour); 
            
                % get the box diagonal length (in pixel as before) 
                box_length = stop - start; 
                box_height = top - bottom;
                diagonal = hypot(box_length, box_height); 
                % conceptutally: trim the diagonal according to vocalization positive time and freq 
                % implementation: trim the diagonal based on each and pick the min 
                % in rare case where it's only one, force 1 as value
                % in case where USV is small, choose the other dimension 
                if sum(any(skel, 1)) == 1 || sum(any(skel, 2)) == 1 
                    diagonal = skelLength;
                elseif (box_length * (T(2) - T(1))) < 0.03 && (box_height * F(2) / 1000) < 10
                    diagonal = diagonal * max( ...
                        (sum(any(skel, 1)) / box_length), ...
                        (sum(any(skel, 2)) / box_height));
                else 
                    diagonal = diagonal * min( ...
                        (sum(any(skel, 1)) / box_length), ...
                        (sum(any(skel, 2)) / box_height));
                end 
    
                % calculate path ratio 
                if skelLength < diagonal 
                    PathRatio = 1 + 0.01*rand; % force case where box is small
                else 
                    PathRatio = skelLength / diagonal; 
                end 
    
                % could also add another section here to calculate boundary length 
                % use bwboundaries(contour) and then similar approach 
                % but think about normalization or something first 
             
    %             % plot it 
    %             subplot(122)
    %             imagesc(T(idx_xmin:idx_xmax), F, contour); hold on; 
    %             axis xy; 
    %             xlabel('Time (s)');
    %             ylabel('Frequency (Hz)');
    %             colormap inferno;
    %             colorbar;
    %             set(gca, 'TickDir', 'out')
    %             % add a box
    %             rectangle('Position', Calls.Box(j, :),'EdgeColor', 'g');
    %             % plot skeleton over it
    %             % get pixel indices
    %             [r, c] = find(skel);
    %             % map to axis coordinates
    %             Tx = T(idx_xmin:idx_xmax);          % time axis for the shown columns
    %             plot(Tx(c), F(r), 'b.', 'MarkerSize', 2);
    %             title(PathRatio);
    %             set(gcf, 'Units','pixels', 'Position',[100 100 575 180]);
               
                % add call data to table
                df_mouse = [df_mouse; table({experiment.USV}, skelLength, PathRatio, VariableNames={'usvfile', 'PathLength', 'PathRatio'})];
        
            end % call loop end 

            % save data 
            writetable(df_mouse, [folder2save experiment.USV '.csv'], 'QuoteStrings', true);
            % release memory 
            clearvars F T P P_rel
    
        end % Calls size check end

        % release memory 
        clearvars Calls

    end % repeat_calc check end    
end % experiment loop end 


%% section 2 to aggregate everything together into one file 

% initialize global df accordingly 
% if exisits and don't wanna repeat, load and trim experiments list
if repeat_calc == 0 && exist('Q:\Personal\Tony\Analysis\USV_csvs\ephysUSV_call_PathRatio.csv', 'file')
    df = readtable('Q:\Personal\Tony\Analysis\USV_csvs\ephysUSV_call_PathRatio.csv'); 
else 
    df = []; 
end 

% loop through experiments
for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % if the experiment met criteria to be calculated before 
    if exist([folder2save experiment.USV '.csv'], 'file')
        % load mouse dataframe
        df_mouse = readtable([folder2save experiment.USV '.csv']);
        % aggregate and add to total df 
        df = [df; df_mouse];
    end 
end

% save the global dataframe at the end 
writetable(df, 'Q:\Personal\Tony\Analysis\USV_csvs\ephysUSV_call_PathRatio.csv', 'QuoteStrings', true);
