function xcorr_binned = get_xcorr_binned(sp_train0, sp_train1, maxLag, bin_size)

% find spikes
spikes1 = find(sp_train0);
spikes2 = find(sp_train1);
% turn them into matrices of the same size (to speed up computations later)
spikes1 = repmat(spikes1, numel(spikes2), 1);
spikes2 = repmat(spikes2, size(spikes1, 2), 1)';
% initialize
xcorr_binned = NaN(maxLag * 2 + 1, 1);
% set lags
lags = - maxLag : maxLag;
for lag_idx = 1 : numel(lags)
    spikes2_shifted = spikes2 + lags(lag_idx);
    xcorr_binned(lag_idx) = sum(sum(abs(spikes1 - spikes2_shifted) < bin_size / 2));
end
