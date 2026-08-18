




clear
% load call file
load('Q:\Personal\Tony\Analysis\Results_USV\T0000190 2024-06-28  4_28 PM.mat')


% spectrogram params
windowLength = 1000;             % Window length in samples (4 ms)
window = hamming(windowLength);  % Hamming window
noverlap = windowLength / 2;     % 50% overlap
nfft = 1024;                     % Number of FFT points

audiorec = audioread(audiodata.Filename);

% Read audio
audiorec = audioread(audiodata.Filename);

% Make sure it is a column vector
audiorec = audiorec(:);

Fs = audiodata.SampleRate;

% get spectrogram of audio file
[~, F, T, P] = spectrogram(audiorec, window, noverlap, nfft, audiodata.SampleRate, 'yaxis');



% Plot spectrogram in dB
figure;
imagesc(T, F/1000, 10*log10(P));   % F/1000 converts Hz to kHz
axis xy;                           % low freq bottom, high freq top
colormap inferno;                  % or use parula if inferno unavailable
colorbar;
clim([-120 -65])
xlabel('Time (s)');
ylabel('Frequency (kHz)');
title('Audio spectrogram');


% --------------------------------------------------------
% Suppress horizontal noise bands without smearing the band
% --------------------------------------------------------

Sdb = 10*log10(P + eps);     % work in dB for visualization
SdbClean = Sdb;

% Frequency bands to clean, in Hz
noiseBands = [
    23e3   26.5e3;     % 24–26 kHz
    47e3 51.5e3;     % 47.5–50 kHz
    69e3  70e3; 
    89e3   91e3      % 89–91 kHz
];

% Background estimation settings
bgGapHz   = 500;      % gap between cleaned band and background region
bgWidthHz = 1500;     % width of background region on each side

alpha = 0.7;          % correction strength: 0 = none, 1 = strong
preserveDb = 3;       % allow signal to remain this many dB above background

for i = 1:size(noiseBands, 1)

    fLow  = noiseBands(i, 1);
    fHigh = noiseBands(i, 2);

    % bins inside the noise band
    bandIdx = F >= fLow & F <= fHigh;

    % background bins below and above the noise band
    bgLowIdx = F >= fLow - bgGapHz - bgWidthHz & ...
               F <= fLow - bgGapHz;

    bgHighIdx = F >= fHigh + bgGapHz & ...
                F <= fHigh + bgGapHz + bgWidthHz;

    if sum(bandIdx) == 0 || sum(bgLowIdx) < 2 || sum(bgHighIdx) < 2
        warning('Not enough frequency bins around %.1f–%.1f kHz.', ...
            fLow/1000, fHigh/1000);
        continue
    end

    % background level below and above the band, for each time point
    bgLow  = median(Sdb(bgLowIdx, :), 1);
    bgHigh = median(Sdb(bgHighIdx, :), 1);

    % interpolate expected background across the cleaned band
    w = (F(bandIdx) - fLow) / (fHigh - fLow);   % 0 to 1 across band
    bgInterp = (1 - w) .* bgLow + w .* bgHigh;

    % only reduce values that are brighter than local background + preserveDb
    excess = SdbClean(bandIdx, :) - (bgInterp + preserveDb);
    excess(excess < 0) = 0;

    SdbClean(bandIdx, :) = SdbClean(bandIdx, :) - alpha * excess;
end



% Plot spectrogram in dB
figure;
imagesc(T, F/1000, SdbClean);   % F/1000 converts Hz to kHz
axis xy;                           % low freq bottom, high freq top
colormap inferno;                  % or use parula if inferno unavailable
colorbar;
clim([-111 -65])
xlabel('Time (s)');
ylabel('Frequency (kHz)');
title('clean audio spectrogram');


% Create audio time vector
audioTime = (0:length(audiorec)-1) / Fs;

figure;

tiledlayout(2, 1, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

% ---------------------------------------------------------
% Top: spectrogram
% ---------------------------------------------------------
ax1 = nexttile;

imagesc(T, F/1000, SdbClean);
axis xy;
colormap inferno;
colorbar;
clim([-111 -65]);
ylabel('Frequency (kHz)');
title('Clean audio spectrogram');

% ---------------------------------------------------------
% Bottom: audio time series
% ---------------------------------------------------------
ax2 = nexttile;

plot(audioTime, audiorec, 'k');
xlabel('Time (s)');
ylabel('Amplitude');
title('Audio waveform');

% Link x-axes
linkaxes([ax1 ax2], 'x');

% Optional: same time range for both
xlim([T(1) T(end)]);