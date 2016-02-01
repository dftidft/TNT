function [pts, ind_pts] = pt_in_region( keypoints, pos, sz, img_sz )
% filter keypoints in the region
% pos - [y x]
% sz - [h w]
top = max(1, pos(1) - sz(1) / 2);
left = max(1, pos(2) - sz(2) / 2);
bottom = min(img_sz(1), pos(1) + sz(1) / 2);
right = min(img_sz(2), pos(2) + sz(2) / 2);

ind_pts = keypoints(:, 1) >=  left ...
    & keypoints(:, 2) >= top ...
    & keypoints(:, 1) <= right ...
    & keypoints(:, 2) <= bottom;

pts = keypoints(ind_pts, :);

end

