function tdmi = getTdMI(experiment, vector1, vector2, bin, shift, area1, area2, save_data, folder2save, notes) 
% Tony, Mar 2023
% calculate time delayed mutual information between two spike trains 
% input: 
%     - two vectors: eg. spike trains. In case of none equal length, the short one is zero-padded at the end 
%     - bin: in miliseconds, step of each shift 
%     - shift: in miliseconds, how much to shift the vector 1 in ONE direction. therefore, the entire shift is 2 x shift 
% output: 
%     - a single vector of time-delayed mutual information
% Intepretation: a peak on the right means vector 1 is leading, vice versa 
% This requires the Information Theory Toolbox! 

% compare size and zero-pad 
if numel(vector1) > numel(vector2)
    vector2((numel(vector2) + 1) : numel(vector1)) = 0; 
elseif numel(vector1) < numel(vector2)
    vector1((numel(vector1) + 1) : numel(vector2)) = 0; 
end 

% initialize result vector 
tdmi = NaN([1, shift/bin * 2 + 1]); 
b = -shift/bin : shift/bin; 

% loop through time shifts to compute things
for s =  -shift/bin : shift/bin
    % shift vector 1
    vector1s = circshift(vector1, s*bin); 
    % zero-pad head or tail 
    if s < 0
        vector1s(end + s*bin + 1 : end) = 0;
    elseif s > 0 
        vector1s(1 : s*bin) = 0; 
    end 

    % compute mutual information 
    tdmi(b == s) = mutInfo(vector1s, vector2); 
end 

TdMI.tdmi = tdmi; 
TdMI.shift = shift; 
TdMI.bin = bin; 
TdMI.area1 = area1; 
TdMI.area2 = area2; 
TdMI.notes = notes; 

% save data 
if save_data == 1
    if ~exist([folder2save area1 area2], 'dir')
        mkdir([folder2save area1 area2])
    end 
    save([folder2save area1 area2 '\' experiment.name], 'TdMI'); 
end

end 

% % test code: 
% bin = 50; 
% shift = 2000; 
% vector1 = randi([0 1], 1, 10000);
% vector2 = circshift(vector1, 1000); % vector2 lag vector1 by 20 bins
% 
% plot(b, tdmi);
