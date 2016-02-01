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

for iframe = 1 : 2
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
        
        % Detect keypoints 
        keypoints_cv = detector.detect(gray);
        keypoints = cat(1, keypoints_cv.pt);
        [active_keypoints, ind_active_keypoints] = pt_in_region(keypoints, pos, win_sz, img_sz);
        
        % Get keypoint index: active keypoints in all keypoints
        ind_ak_in_all = find(ind_active_keypoints);
        
        % Set active keypoints
        [keypoints_fg, ind_keypoints_fg] = pt_in_region(active_keypoints, pos, target_sz, img_sz);
        keypoints_fg = [keypoints_fg, (1 : size(keypoints_fg, 1))'];
        keypoints_bg = active_keypoints(~ind_keypoints_fg, :);
        keypoints_bg = [keypoints_bg, -ones(size(keypoints_bg, 1), 1)];
        active_keypoints = [keypoints_fg; keypoints_bg]; 
        
        % Get keypoint index: foreground/background keypoints in active keypoints
        ind_fb_in_ak = [find(ind_keypoints_fg);find(~ind_keypoints_fg)];
        active_keypoints_cv = keypoints_cv(ind_ak_in_all(ind_fb_in_ak));
        active_features = detector.compute(gray, active_keypoints_cv);
    end
    
    % Keypoint matching
    if iframe > 1
        keypoints_cv = detector.detect(gray);
        keypoints = cat(1, keypoints_cv.pt);
        [query_keypoints, ind_query_keypoints] = pt_in_region(keypoints, pos, win_sz, img_sz);
        ind_query_keypoints = find(ind_query_keypoints);
        query_keypoints_cv = keypoints_cv(ind_query_keypoints);
        query_features = detector.compute(gray, query_keypoints_cv);
        matches = matcher.knnMatch(query_features, active_features, 2);
        
        % kNN matching
        pt_matches = [];
        for imatch = 1 : numel(matches)
            sim1 = 1 - matches{imatch}(1).distance / DIST_MAX;
            sim2 = 1 - matches{imatch}(2).distance / DIST_MAX;
            src_pt = active_keypoints(matches{imatch}(1).trainIdx + 1, 1:2);
            dst_pt = query_keypoints(matches{imatch}(1).queryIdx + 1, 1:2);
            spatial_dist = sqrt(sum((src_pt - dst_pt) .^ 2));
            if sim1 > THR_CONF && (1 - sim1) / (1 - sim2) < THR_RATIO && spatial_dist < THR_SPACE_DIST
                pt_matches(end +  1, :) = [src_pt, dst_pt, active_keypoints(matches{imatch}(1).trainIdx + 1, 3)];
            end
        end
        
        % Ransac affine estimate
        % affine background
        fg_pt_matches = pt_matches(pt_matches(:, 5) ~= -1, :);
        % H = cv.findHomography(fg_pt_matches(:, 1:2), fg_pt_matches(:, 3:4), 'Method', 'Ransac');
        % tform = estimateGeometricTransform(fg_pt_matches(:, 1:2), fg_pt_matches(:, 3:4), 'affine');
    end
    
    %{
    if iframe == 1
        img_h = imshow(img, 'Border','tight', 'InitialMag', 100);
        hold on;
    else
        set(img_h, 'CData', img);
    end
    
    if iframe > 1
         plot(fg_pt_matches(:, 1), fg_pt_matches(:, 2), '.', 'Color', [1, 0, 0]);
         plot(fg_pt_matches(:, 3), fg_pt_matches(:, 4), '.', 'Color', [0, 1, 1]);
    end
    %}

    % Debug
    % 显示点匹配情况
    %{
    if iframe > 1
        showMatchedFeatures(prev_gray, gray,fg_pt_matches(:, 1:2), fg_pt_matches(:, 3:4), 'Montage');
    end
    %}

    if double(get(gcf,'CurrentCharacter')) == 27
        break;
    end
    pause(0.03);
    
    prev_gray = gray;
    
end

