function update_visualization_func = show_video(img_files, video_path, resize_image)
%SHOW_VIDEO
%   Visualizes a tracker in an interactive figure, given a cell array of
%   image file names, their path, and whether to resize the images to
%   half size or not.
%
%   This function returns an UPDATE_VISUALIZATION function handle, that
%   can be called with a frame number and a bounding box [x, y, width,
%   height], as soon as the results for a new frame have been calculated.
%   This way, your results are shown in real-time, but they are also
%   remembered so you can navigate and inspect the video afterwards.
%   Press 'Esc' to send a stop signal (returned by UPDATE_VISUALIZATION).
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/


	%store one instance per frame
	num_frames = numel(img_files);
	database = cell(num_frames,1);

	%create window
	[fig_h, axes_h, unused, scroll] = videofig(num_frames, @redraw, [], [], @on_key_press);  %#ok, unused outputs
	set(fig_h, 'Number','off', 'Name', ['Tracker - ' video_path])
	axis off;
	
	%image and rectangle handles start empty, they are initialized later
	im_h = [];
	rect_h = [];
    pts_h = [];
    pts_h2 = [];
    text_h = [];
	
	update_visualization_func = @update_visualization;
	stop_tracker = false;
	

	function stop = update_visualization(frame, data)
		%store the tracker instance for one frame, and show it. returns
		%true if processing should stop (user pressed 'Esc').
		database{frame} = data;
		scroll(frame);
		stop = stop_tracker;
	end

	function redraw(frame)
		%render main image
		im = imread([video_path img_files{frame}]);
		if size(im,3) > 1,
			im = rgb2gray(im);
		end
		if resize_image,
			im = imresize(im, 0.5);
		end
		
		if isempty(im_h),  %create image
			im_h = imshow(im, 'Border','tight', 'InitialMag',200, 'Parent',axes_h);
		else  %just update it
			set(im_h, 'CData', im)
		end
		
		%render target bounding box for this frame
        %{
		if isempty(rect_h),  %create it for the first time
			rect_h = rectangle('Position',[0,0,1,1], 'EdgeColor','g', 'Parent',axes_h);
		end
		if ~isempty(database{frame}),
			set(rect_h, 'Visible', 'on', 'Position', database{frame}.box);
		else
			set(rect_h, 'Visible', 'off');
		end
        %}
        hold on;
        if isempty(rect_h),  %create it for the first time
            rect_h = DrawRectangle([1, 1, 1, 1, 1]);
        end
        if ~isempty(database{frame}),
            delete(rect_h);
            rect_h = DrawRectangle(database{frame}.rotated_rect);
        else
            set(rect_h, 'Visible', 'off');
        end

        if isempty(pts_h),  %create it for the first time
            pts_h = plot(0, 0);
        end
        if ~isempty(database{frame}) && frame > 1,
            delete(pts_h);
            pts_h = plot(database{frame}.fg_pt_matches(:, 3), database{frame}.fg_pt_matches(:, 4), '.', 'Color', [1, 0, 0]);
        else
            set(pts_h, 'Visible', 'off');
        end

        if isempty(pts_h2),  %create it for the first time
            pts_h2 = plot(0, 0);
        end
        if ~isempty(database{frame}) && frame > 1,
            delete(pts_h2);
            pts_h2 = plot(database{frame}.bg_pt_matches(:, 3), database{frame}.bg_pt_matches(:, 4), '.', 'Color', [0, 1, 1]);
        else
            set(pts_h2, 'Visible', 'off');
        end

        if isempty(text_h),  %create it for the first time
            text_h = text(10, 10, '0');
        end
        if ~isempty(database{frame}),
            delete(text_h);
            text_h = text(10, 10, sprintf('%d', frame), 'Color', [1, 0, 0]);
        else
            set(text_h, 'Visible', 'off');
        end
        
	end

	function on_key_press(key)
		if strcmp(key, 'escape'),  %stop on 'Esc'
			stop_tracker = true;
		end
	end

end

