function [tracked_pts, key_pts] = fb_flow(gray, prev_gray, keypoints, thr)
% Foward-backward optical flow tracking
% 返回跟踪点以及与之一一对应的原关键点

if nargin < 4
    thr = 20;
end

[next_pts, status] = cv.calcOpticalFlowPyrLK(prev_gray, gray, keypoints);
% next_pts = cv.calcOpticalFlowPyrLK(prev_gray, gray, keypoints);
back_prev_pts = cv.calcOpticalFlowPyrLK(gray, prev_gray, next_pts);
back_prev_pts = cat(1, back_prev_pts{:});
dist = sqrt(sum((back_prev_pts - keypoints) .^ 2, 2));

status = dist < thr & status;
next_pts = next_pts(status);
tracked_pts = cat(1, next_pts{:});
key_pts = keypoints(status, :);

end

