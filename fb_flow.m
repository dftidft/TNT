function [tracked_pts, key_pts] = fb_flow(gray, prev_gray, keypoints, thr)
% Foward-backward optical flow tracking
% ���ظ��ٵ��Լ���֮һһ��Ӧ��ԭ�ؼ���

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

