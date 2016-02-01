function [scale, rotation] = affine_estimate_by_center(keypoints, prev_keypoints, center, prev_center)

n = size(keypoints, 1);

prev_v = prev_keypoints - repmat([prev_center(2), prev_center(1)], n, 1);
prev_dist_pairs = sqrt(sum(prev_v .* prev_v, 2));
prev_angle_pairs = atan2(prev_v(:, 2), prev_v(:, 1));

v = keypoints - repmat([center(2), center(1)], n, 1);
dist_pairs = sqrt(sum(v .* v, 2));
angle_pairs = atan2(v(:, 2), v(:, 1));

diff_scale = dist_pairs ./ prev_dist_pairs;
diff_scale = diff_scale(~isnan(diff_scale));
diff_angle = angle_pairs - prev_angle_pairs;

long_way_angles = abs(diff_angle) > pi;
diff_angle(long_way_angles) = diff_angle(long_way_angles) - sign(diff_angle(long_way_angles)) * 2 * pi;
scale = mean(diff_scale);
rotation = mean(diff_angle);

end

