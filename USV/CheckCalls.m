

% Parameters
% fs = 250000;                     % Sampling rate in Hz
windowLength = 1000;             % Window length in samples (4 ms)
window = hamming(windowLength);  % Hamming window
noverlap = windowLength / 2;     % 50% overlap
nfft = 1024;                     % Number of FFT points

% Compute and display the spectrogram
[S, F, T, P] = spectrogram(data, window, noverlap, nfft, fs, 'yaxis');

figure;
imagesc(T, F, 10 * log10(P)); % Manual plot of PSD in dB/Hz
axis xy;
colorbar;
colormap inferno;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Manual Spectrogram (dB/Hz)');




% Enhance the plot
title('Spectrogram of Audio Signal');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colormap inferno;
colorbar;
caxis([-130 -50])