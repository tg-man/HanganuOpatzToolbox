function norm_xcov = getXcov(spike_matrix0, spike_matrix1, bin_size, bin_size_corr, maxLag)
% by Mattia, 07.23, based on Sirota et al., 2008: https://pubmed.ncbi.nlm.nih.gov/19038224/
% computes spike-spike cross-covariance between units belonging to two
% different spike matrices

% inputs:
% spike_matrix0: spikes for brain area 0, dimensions are num_units * time
% spike_matrix1: as above for brain area 1
% bin_size : the bin size in which the spike_matrix is binned (in ms). this
%            should generally be one if you are using the standard spike
%            matrices
% bin_size_corr : the bin size for which to compute the correlation (ie to
%                 consider spikes as co-occurring); also this is in ms. in
%                 the paper this is set at 15.
% maxLag : maximum lag for which to compute the cross-covariance (in ms).
%          in the paper this is set at 512

% output:
% norm_xcov = normalized cross-covariance between all unit pairs of the two
% psike matrices for the bins going from -maxLag to +maxLag

% convert to seconds
bin_size = bin_size / 1000;
% initialize variables
norm_xcov = NaN(size(spike_matrix0, 1) * size(spike_matrix1, 1), maxLag * 2 + 1);
% length of rec = length of longest spike matrix (in seconds)
len_rec = max([length(spike_matrix0) length(spike_matrix1)]) / 1000; % in seconds

% loop over all unit pairs
idx_pair = 1;
for unit1 = 1 : size(spike_matrix0, 1)
    % get firing rates for spike matrix 0
    f_rate1 = sum(spike_matrix0(unit1, :)) / len_rec;
    for unit2 = 1 : size(spike_matrix1, 1)
        % get firing rates for spike matrix 1
        f_rate2 = sum(spike_matrix1(unit2, :)) / len_rec;
        % compute binned xcorr
        xcorr_binned = get_xcorr_binned(spike_matrix0(unit1, :), spike_matrix1(unit2, :), maxLag, bin_size_corr);
        % get xcov by normalizing by product size of bin * recording length minus product of firing rates
        est_xcov = xcorr_binned ./ (bin_size * len_rec) - f_rate1 * f_rate2;
        % normalize xcov
        norm_xcov(idx_pair, :) = est_xcov * sqrt((bin_size * len_rec) / (f_rate1 * f_rate2));
        idx_pair = idx_pair + 1;
    end
end

end