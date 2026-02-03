%% Contour detection 
% alternative to DeepSqueak contour detection 
% by a absolute threshold and a relative threshold (z-score on the frequency axis) 

clear 

% load call file
load('Q:\Personal\Tony\Analysis\Results_USV\T0000321 2025-11-04  4_56 PM.mat')
% filter only accepted calls 
Calls = Calls(Calls.Accept, :); 
Calls.Box(:, 2) = Calls.Box(:, 2)*1000; % from kHz to Hz 
Calls.Box(:, 4) = Calls.Box(:, 4)*1000; % from kHz to Hz 
% load audio file 
audio = audioread(audiodata.Filename);

% Parameters
windowLength = 1000;             % Window length in samples (4 ms)
window = hamming(windowLength);  % Hamming window
noverlap = windowLength / 2;     % 50% overlap
nfft = 1024;                     % Number of FFT points

% plot spectorgram 
[S, F, T, P] = spectrogram(audio, window, noverlap, nfft, audiodata.SampleRate, 'yaxis');
figure;
imagesc(T, F, 10 * log10(P)); % Manual plot of PSD in dB
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Manual Spectrogram (dB)');
colormap inferno;
colorbar;
clim([-130 -50]); 
set(gca, 'TickDir', 'out')

% all power in dB 
A = 10*log10(P); 

% take the zscore of P for relative spectrogram 
P_rel = zscore(10*log10(P), [], 2);

% plot only a background noise portion 
% all starting time stamps
x1 = Calls.Box(:, 1); 
% all finishing time stamps 
x2 = x1 + Calls.Box(:, 3); 
% delay duration 
delay = x2(2:end) - x1(1:end-1); 
% find the index of the longest delay duration 
[M, I] = max(delay); 
% extract a piece of spectrogram with only background signal 
background = A(:, (T > (Calls.Box(I, 1) + Calls.Box(I, 3))) & (T < Calls.Box(I + 1, 1)));
% plot the background 
figure; 
imagesc(T((T > Calls.Box(I,1) + Calls.Box(I,3)) & (T < Calls.Box(I+1,1))), F, background)
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colormap inferno;
colorbar;
clim([-130 -50]); 
set(gca, 'TickDir', 'out')
title('Background')

% take only the ultrasonic portion of power 
background_us = background(F > 20000, :); 
A_us = A(F > 20000, :); 
% plot into histogram
figure; 
histogram(A_us(:), 'FaceColor', 'red', 'EdgeColor', 'none'); hold on; % all
histogram(background_us(:), 'FaceColor', 'blue', 'EdgeColor', 'none'); %background
set(gca, 'YScale', 'log'); 
title('histogram of power values')

% detection parameters 
threshold_abs = -100; % prctile(background(:), 90); % in dB 
threshold_rel = 1.5; 

% gaussian kernel
smoothing = fspecial('gaussian', [5 5], 0.9); 

% loop through each calls to save a fig of just the one call
for j = 4 : 80 : (size(Calls, 1) - 1) % first and last call aren't calls, but artificial markers 
% for j = [484 833 1284]

    % find the index in the time vector for this call
    idx_xmin = find(T > (Calls.Box(j,1) - 0.08), 1); 
    idx_xmax = find(T > (Calls.Box(j,1) + 0.17), 1); 
    
    % create the figure
    figure;
    subplot(121);
    imagesc(T(idx_xmin:idx_xmax), F, 10*log10(P(:, idx_xmin:idx_xmax)));
    axis xy;
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    colormap inferno;
%     colorbar;
    clim([-115 -73]);
    set(gca, 'TickDir', 'out')
    title(j)
    % add a box
    rectangle('Position', Calls.Box(j, :),'EdgeColor' , 'g');

    % absolute thresholding 
    C_abs = conv2(10*log10(P(:, idx_xmin:idx_xmax)), smoothing, 'same') > threshold_abs; 
%     subplot(142)
%     imagesc(T(idx_xmin:idx_xmax), F, C_abs);
%     axis xy;
%     xlabel('Time (s)');
%     ylabel('Frequency (Hz)');
%     colormap inferno;
%     colorbar;
%     set(gca, 'TickDir', 'out')
%     title('abs thresholding')
%     % add a box
%     rectangle('Position', Calls.Box(j, :),'EdgeColor', 'g');

    % relative thresholding 
    C_rel = conv2(P_rel(:, idx_xmin:idx_xmax), smoothing, 'same') > threshold_rel; 
%     subplot(143);
%     imagesc(T(idx_xmin:idx_xmax), F, C_rel);
%     axis xy;
%     xlabel('Time (s)');
%     ylabel('Frequency (Hz)');
%     colormap inferno;
%     colorbar;
%     set(gca, 'TickDir', 'out')
%     title('rel thresholding')
%     % add a box
%     rectangle('Position', Calls.Box(j, :),'EdgeColor', 'g');

    % get initial contour 
    contour = C_rel & C_abs;

    % get rid of area outside of the box
    % find box stamps 
    start = find(T(idx_xmin:idx_xmax) > Calls.Box(j,1), 1) ;
    stop = find(T(idx_xmin:idx_xmax) > (Calls.Box(j,1) + Calls.Box(j,3)), 1);
    top = find(F > (Calls.Box(j, 2) + Calls.Box(j, 4)), 1); 
    bottom = find(F > Calls.Box(j, 2), 1);
    % clear area outside of box 
    contour(1:bottom, :) = 0; 
    contour(top:end, :) = 0; 
    contour(:, 1:start) = 0; 
    contour(:, stop:end) = 0;

%     % plot combined thresholding
%     subplot(142); 
%     imagesc(T(idx_xmin:idx_xmax), F, contour);
%     axis xy;
%     xlabel('Time (s)');
%     ylabel('Frequency (Hz)');
%     colormap inferno;
%     colorbar;
%     set(gca, 'TickDir', 'out')
%     title('combi thresholding')
%     % add a box
%     rectangle('Position', Calls.Box(j, :),'EdgeColor', 'g');

    % connect sparse dots ONLY while leave thick contours alone
    % get skeleton of the contour
    skeleton = bwmorph(contour, 'skel', Inf); 
    % dilate the skeleton
    se = strel('rectangle', [12, 4]);
    skeleton = imdilate(skeleton, se);
    % thin it back down 
    skeleton = bwmorph(skeleton, 'thin', 3);
    % union with original thresholded contour
    contour = contour | skeleton; 
%     % plot it 
%     subplot(143)
%     imagesc(T(idx_xmin:idx_xmax), F, contour);
%     axis xy; 
%     xlabel('Time (s)');
%     ylabel('Frequency (Hz)');
%     colormap inferno;
%     colorbar;
%     set(gca, 'TickDir', 'out')
%     title('after skel dilation')
%     % add a box
%     rectangle('Position', Calls.Box(j, :),'EdgeColor', 'g');

    % connected close by objects
    se = strel('rectangle', [20, 4]);  % spatial element 
    contour = imclose(contour, se);
    % bridge 1 pixel gaps - but repeat 10 times
    contour = bwmorph(contour, 'bridge', 10);
    % plot it 
    subplot(122)
    imagesc(T(idx_xmin:idx_xmax), F, contour); hold on; 
    axis xy; 
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    colormap inferno;
%     colorbar;
    set(gca, 'TickDir', 'out')
%     title('after objects closing')
    % add a box
    rectangle('Position', Calls.Box(j, :),'EdgeColor', 'g');
%     % plot skeleton over it 
%     % get pixel indices
%     [r, c] = find(bwskel(contour));
%     % map to axis coordinates
%     Tx = T(idx_xmin:idx_xmax);          % time axis for the shown columns
%     plot(Tx(c), F(r), 'b.', 'MarkerSize', 2);
    set(gcf, 'Units','pixels', 'Position',[100 100 575 180])


%     % despeckle 
%     R = 4;                     % radius
%     kernel = ones(2*R+1);      % square neighborhood
%     % Count number of 1s in each square neighborhood
%     count = conv2(contour, kernel, 'same');
%     % Pixels where count too low are isolated.
%     contour(count < 5) = 0;
%      % plot despeckled contour
%     subplot(144)
%     imagesc(T(idx_xmin:idx_xmax), F, contour);
%     axis xy;
%     xlabel('Time (s)');
%     ylabel('Frequency (Hz)');
%     colormap inferno;
%     colorbar;
%     set(gca, 'TickDir', 'out')
%     title('after despeckle')
%     % add a box
%     rectangle('Position', Calls.Box(j, :),'EdgeColor', 'g');

end 
% 
% 
% % use entropy to get 
% a_call = A(:, idx_xmin:idx_xmax);
% a_call(~contour) = 0;
% entropy(a_call)



