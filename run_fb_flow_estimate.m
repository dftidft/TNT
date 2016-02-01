% Add mexopencv lib
addpath 'D:\Project\Matlab\mexopencv'

% Parameters
padding = 2;  % Extra area surrounding the target
THR_CONF = 0.75; % Point-wise matching confidence
THR_RATIO = 0.8; % Point-wise matching confidence ratio between 1st and 2nd best match
THR_SPACE_DIST = 20; % Spatial distance between correspondence points

% Input
SEQ_NAME = 'motorrolling';
IMG_DIR = sprintf('D:/Dataset/tracking/seq_bench/%s', SEQ_NAME);
GT_FILE_NAME = 'groundtruth_rect.txt';
detector = cv.BRISK();

DIST_MAX = 512;
matcher = cv.DescriptorMatcher('BruteForce-Hamming');

gt_file_path = sprintf('%s/%s', IMG_DIR, GT_FILE_NAME);
gt_rects = importdata(gt_file_path);
scale = 1;

pos = [gt_rects(1, 2) + gt_rects(1, 4) / 2, gt_rects(1, 1) + gt_rects(1, 3) / 2];
target_sz = [gt_rects(1, 4),  gt_rects(1, 3)];
win_sz = target_sz * (1 + padding);

center = pos;
prev_center = center;

for iframe = 1 : 10
    % Read input
    img_file_path = sprintf('%s/img/%04d.jpg', IMG_DIR, iframe);
    img = imread(img_file_path);
    if ndims(img) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end

    % Init
    if iframe == 1
        img_sz = size(gray);
        keypoints_cv = detector.detect(gray);
        keypoints = cat(1, keypoints_cv.pt);
        keypoints = pt_in_region(keypoints, pos, target_sz, img_sz); 
    end
    
    % Keypoint matching
    if iframe > 1
        [tracked_pts, key_pts] = fb_flow(gray, prev_gray, keypoints);
        pos = [gt_rects(iframe, 2) + gt_rects(iframe, 4) / 2, gt_rects(iframe, 1) + gt_rects(iframe, 3) / 2];
        target_sz = [gt_rects(iframe, 4),  gt_rects(iframe, 3)];
        win_sz = target_sz * (1 + padding);
        prev_center = center;
        center = pos;
        
        %[scale, rotation] = affine_estimate_by_center(tracked_pts, key_pts, center, prev_center);
        [mcenter, scale, rotation] = affine_estimate(tracked_pts, key_pts);
        disp(rotation);
    end
    
    if iframe == 1
        img_h = imshow(img, 'Border','tight', 'InitialMag', 100);
        hold on;
    else
        set(img_h, 'CData', img);
    end
    
    if iframe > 1
         plot(tracked_pts(:, 1), tracked_pts(:, 2), '.', 'Color', [1, 0, 0]);
         plot(key_pts(:, 1), key_pts(:, 2), '.', 'Color', [0, 1, 1]);
    end

    % Debug
    % 显示点匹配情况
    %{
    if iframe > 1
        showMatchedFeatures(prev_gray, gray,fg_pt_matches(:, 1:2), fg_pt_matches(:, 3:4), 'Montage');
    end
    %}

    %{
    if double(get(gcf,'CurrentCharacter')) == 27
        break;
    end
    pause(0.03);
    %}
    
    % Update
    if iframe > 1
        keypoints_cv = detector.detect(gray);
        keypoints = cat(1, keypoints_cv.pt);
        keypoints = pt_in_region(keypoints, pos, target_sz, img_sz);
    end
    
    prev_gray = gray;
    
end

