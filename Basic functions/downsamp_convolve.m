function spike_matrix_dc = downsamp_convolve(spike_matrix, kernel, downsamp)

spike_matrix = full(spike_matrix);
% get max number of columns divisible by downsamp
cols2keep = floor(size(spike_matrix, 2) / downsamp);
% reduce to downsamp-ms wide bins
spike_matrix_dc = squeeze(mean(reshape(spike_matrix(:, 1 : cols2keep * downsamp), ...
    size(spike_matrix, 1), downsamp, []), 2));
if ~ isempty(kernel)
    % downsample also the kernel
    kernel = kernel(1 : downsamp : end);
    % convolve with the given kernel
    for unit = 1 : size(spike_matrix, 1)
        spike_matrix_dc(unit, :) = conv(spike_matrix_dc(unit, :), kernel, 'same');
    end
end
end