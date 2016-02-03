base_path = 'D:/Dataset/tracking/seq_bench/';
video = 'dog1';
show_visualization = true;
[img_files, pos, target_sz, ground_truth, video_path] = load_video_info(base_path, video);

if show_visualization,  %create video interface
    update_visualization = show_video(img_files, video_path, false);
end
%visualization
for iframe = 1 : numel(img_files)
    if show_visualization,
        data.box = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
        stop = update_visualization(iframe, data);
        if stop, break, end  %user pressed Esc, stop early
        drawnow
        pause(0.05)  %uncomment to run slower
    end
end