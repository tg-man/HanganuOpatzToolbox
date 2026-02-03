function [skel, length] = getContourSkeletonLength(contour)

skel = bwskel(contour);

% label skeleton pixels
[idxY, idxX] = find(skel);
lin = find(skel);

% 8-neighborhood offsets
offs = [ -1 -1; -1 0; -1 1;
          0 -1;        0 1;
          1 -1;  1 0;  1 1];

H = size(skel,1); W = size(skel,2);

% initialize length 
edgeSum = 0;
% loop through each pixel, count neighbors, compute distance, and add 
for k = 1:numel(lin)
    y = idxY(k); x = idxX(k);
    for o = 1:size(offs,1)
        yy = y + offs(o,1);
        xx = x + offs(o,2);
        if yy>=1 && yy<=H && xx>=1 && xx<=W && skel(yy,xx)
            % only count each edge once
            lin2 = sub2ind([H W], yy, xx);
            if lin2 > lin(k)
                edgeSum = edgeSum + hypot(offs(o,2), offs(o,1)); % 1 or sqrt(2)
            end
        end
    end
end

length = edgeSum;

end 