function [mcenter, scale, rotation] = affine_estimate(keypoints, prev_keypoints)
% Estimate mean center, scale and rotation by the spatial change of 
% keypoints & prev_keypoints pairs 

n = size(keypoints, 1);
ind_pairs = VChooseKO(1 : n, 2);
ind1 = ind_pairs(:, 1);
ind2 = ind_pairs(:, 2);
prev_v = prev_keypoints(ind1, :) - prev_keypoints(ind2, :);
prev_dist_pairs = sqrt(sum(prev_v .* prev_v, 2));
prev_angle_pairs = atan2(prev_v(:, 2), prev_v(:, 1));

v = keypoints(ind1, :) - keypoints(ind2, :);
dist_pairs = sqrt(sum(v .* v, 2));
angle_pairs = atan2(v(:, 2), v(:, 1));
diff_scale = dist_pairs ./ prev_dist_pairs;
diff_scale = diff_scale(~isnan(diff_scale));
% disp(dist_point_pairs(isnan(diff_scale)));
% disp(prev_dist_point_pairs(isnan(diff_scale)));
diff_angle = angle_pairs - prev_angle_pairs;
long_way_angles = abs(diff_angle) > pi;
diff_angle(long_way_angles) = diff_angle(long_way_angles) - sign(diff_angle(long_way_angles)) * 2 * pi;
scale = mean(diff_scale);
rotation = mean(diff_angle);
mcenter = mean(keypoints);

end

