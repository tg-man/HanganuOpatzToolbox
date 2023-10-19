function indeces = sort_peak_time(spike_matrix, num_points)

% smooth with moving mean
for idx = 1 : size(spike_matrix, 1)
    spike_matrix(idx, :) = smoothdata(spike_matrix(idx, :), 'movmean', num_points);
end
% find peak
[~, peak_loc] = max(spike_matrix, [] , 2);
% sort peaks
[~, indeces] = sort(peak_loc);

end