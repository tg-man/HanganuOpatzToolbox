
clear; 
% load .wav file 
filename = 'Q:\Personal\Tony\USV\T0000175.wav';
[y, Fs] = audioread(filename);
% clip out sentence 
start = (23*60 + 29)*Fs + 1; % 23:29s 
stop = (23*60 + 32)*Fs; % 23:32s
y_clip = y(start:stop); 


% filter out noise frequency
y  = y_clip;                  % your 3 s clip (column or matrix)
% --- Notch targets (Hz) ---
notchHz = [50000, 47500, 25000];
% --- Set notch width (choose ONE approach) ---
% (A) Use explicit -3 dB bandwidth in Hz (narrow notches, e.g., 1000 Hz total)
BW_hz = 1000;                             % total -3 dB bandwidth around each tone
BW = BW_hz / (Fs/2);                      % normalized bandwidth
% % (B) Or use quality factor Q instead (comment A and uncomment below):
% Q = 50;                                 % higher Q -> narrower notch
% % BW will be set per tone as BW = w0/Q (see inside loop)
% --- Build and apply the cascaded notches ---
y_filt = y;
for f0 = notchHz
    w0 = f0 / (Fs/2);                     % normalized notch frequency (0..1)

    % Choose ONE bandwidth method:
    % Using explicit BW (A):
    [b, a] = iirnotch(w0, BW);

    % % Using Q (B):
    % BW_Q = w0 / Q;                      % normalized BW from Q
    % [b, a] = iirnotch(w0, BW_Q);

    % Zero-phase apply (handles mono or multi-channel)
    y_filt = filtfilt(b, a, y_filt);
end


% tune down white noise
y = y_filt(:);
% 1) Short STFT
win   = hamming(1024,'periodic');
nover = round(0.75*numel(win));
nfft  = 2048;
[S,F,T] = stft(y, Fs, 'Window', win, 'OverlapLength', nover, 'FFTLength', nfft);
% 2) Pick a noise-only time region (in seconds) to profile (edit these!)
noise_win = [0.0 0.5];  % first 0.5 s assumed to be background
noise_cols = T>=noise_win(1) & T<=noise_win(2);
N = median(abs(S(:,noise_cols)).^2, 2);  % noise PSD estimate per bin
% 3) Make a soft mask relative to noise floor
alpha = 1.5;                       % aggressiveness (>1 stronger)
mag2  = abs(S).^2;
gain  = max(0, 1 - alpha*(N ./ (mag2 + eps)));   % Wiener-like mask
S_d   = S .* gain;
% 4) Reconstruct
y_denoised = istft(S_d, Fs, 'Window', win, 'OverlapLength', nover, 'FFTLength', nfft, 'ConjugateSymmetric', true);
Lout = numel(y_denoised); Lin = numel(y);
if Lout < Lin
    y_denoised(Lout+1:Lin,1) = 0;   % zero-pad to match input length
else
    y_denoised = y_denoised(1:Lin); % trim
end


% scale down to audible frequency
y  = y_denoised(:);
t  = (0:numel(y)-1)'/Fs;
% --- Choose the ultrasonic band you care about (example: 60–90 kHz) ---
f1 = 60e3; 
f2 = 90e3;
fC = (f1 + f2)/2;              % band center
fTarget = 8000;                % where you want the band to land (audible)
% --- Mix (shift) the band so its center lands at fTarget ---
y_mix = y .* cos(2*pi*(fC - fTarget).*t);
% --- Low-pass to keep the downshifted copy and suppress the mirror ---
% Keep up to ~20 kHz (so we can play at 48 kHz safely)
y_lp = lowpass(y_mix, 20000, Fs);   % Signal Processing Toolbox
% --- Resample for playback and normalize ---
Fs_out = 20000;
y_play = resample(y_lp, Fs_out, Fs);
y_play = y_play ./ max(1, max(abs(y_play)));


% calibrate dynamic range
y = y_play(:);
y = y ./ max(abs(y)) / 5;            % normalize to ±1


% --- Play (audioplayer is often more robust than sound) ---
p = audioplayer(y, Fs_out);
playblocking(p);

audiowrite('C:\Users\tman\Desktop\usv_audible.wav', y, Fs_out);



y = y_play(:);                        % ensure column

if size(y,2) > 1, y = mean(y,2); end % mono (if stereo)
Fs_plot = Fs_out;                    % or: Fs_plot = Fs;
% Spectrogram params (balanced time/freq resolution for audio)
win   = hamming(2048, 'periodic');
nover = round(0.75 * numel(win));
nfft  = 4096;
% spectrogram transform
[S, F, T, P] = spectrogram(y, win, nover, nfft, Fs_plot, 'yaxis'); % P is power
% plotting 
figure;
imagesc(T, F/1000, 10*log10(P + eps));   % dB, freq in kHz
axis xy; colormap(inferno);
xlabel('Time (s)');
ylabel('Frequency (kHz)');
title('Spectrogram of yplay');
c = colorbar; ylabel(c, 'Power (dB)');
