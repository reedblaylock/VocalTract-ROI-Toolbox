function timeseries = findTimeseries(region, video)
	switch lower(region.type)
		case 'average'
			timeseries = mean(video.matrix(:, region.mask > 0), 2);
		case 'binary'
			% 			norm_matrix = (video.matrix - min(video.matrix(:))) / (max(video.matrix(:)) - min(video.matrix(:)));
			% 			norm_mean = mean(norm_matrix(:, region.mask > 0), 2);
			% 			norm_mean(norm_mean > 0.5) = 1;
			% 			norm_mean(norm_mean <= 0.5) = 0;
			% 			region.timeseries = norm_mean;

			% Normalization adopted from f_int_norm.m in
			% rtmri_seg_v4 by Jangwon Kim
			%
			% Puts the ceiling and the floor intensity to
			% the 90th and 10th quantiles, respectively.
			% Then redistributes the values between a new
			% min and max.
			new_min = 0;
			new_max = 1;

			temp = video.matrix;
			q90 = quantile(temp(:), 0.9);
			q10 = quantile(temp(:), 0.1);
			q90_idx = find(temp > q90);
			q10_idx = find(temp < q10);
			temp(q90_idx) = q90;
			temp(q10_idx) = q10;
			temp = temp - min(temp(:));
			temp = ((temp ./ max(temp(:))) * (new_max - new_min)) + new_min;

			% Get the mean of this region
			% If the intensity of a pixel is greater than
			% half the maximum intensity of the video, set
			% that pixel equal to 1.
			% Set the pixels <= 0.5 to 0.
			binary_norm = mean(temp(:, region.mask > 0), 2);
			binary_norm(binary_norm > 0.5) = 1;
			binary_norm(binary_norm <= 0.5) = 0;
			timeseries = binary_norm;
		case 'centroid'
			% TODO:
			% - Have user supply the seed value instead of taking the max
			% - Have view options for showing x values, y values, both, or
			%   tangential velocity or something
			% - Only show centroid option of the shape is rectangular; if the
			%   shape changes to circular, switch to average
			ROI = get_ROI(video, region, 1);
		
			% TODO: Replace this hack with a real seed-finding method
% 			ROI = video.matrix(1, region.mask > 0);
			[xbar, ybar] = find(ROI == max(ROI(:)));
			xbar = xbar(1);
			ybar = ybar(1);

		
			
			x_cent = zeros(video.nFrames, 1);
			y_cent = zeros(video.nFrames, 1);
			x_raw = zeros(video.nFrames, 1);
			y_raw = zeros(video.nFrames, 1);
% 			x_max = zeros(1, video.nFrames);
% 			y_max = zeros(1, video.nFrames);
% 			mean_int = [];

			%while hasFrame(v)
			for frameNo = 1:video.nFrames
				TEMP = [];
				CENT = [];
				DIST = [];

				% A matrix of the pixel intensity values of the region
				ROI = get_ROI(video, region, frameNo);

				[xraw, yraw] = get_centroid(ROI);
				x_raw(frameNo) = xraw;
				y_raw(frameNo) = yraw;

				OBJ = get_Obj(ROI);
				for i = 1:length(OBJ)
					TEMP{i} = double(ROI) .* double(OBJ{i});
					TEMP{i} = round(mat2gray(TEMP{i}, [0 255]).*256);
					TEMP{i} = uint8(TEMP{i});
					[a,b] = get_centroid(TEMP{i});
					CENT{i} = [a,b];
				end
				for i = 1:length(CENT)
					DIST(i) = sqrt((xbar - CENT{i}(1))^2 + (ybar - CENT{i}(2))^2);
				end
				MinDist = min(DIST(:));
				for i = 1:length(DIST)
					if MinDist == DIST(i)
						centroid = CENT{i};
						xbar = centroid(1);
						ybar = centroid(2);
					end
				end
				x_cent(frameNo) = xbar;
				y_cent(frameNo) = ybar;
			end
			timeseries = [x_cent y_cent];
% 			timeseries = y_cent;
		otherwise
			error('Invalid region type or other error in (vt.Action.findTimeseries.m)');
	end

end

function [ROI] = get_ROI(video, region, frameNo)
	frame = reshape( ...
		video.matrix(frameNo, :), ...
		video.width, ...
		video.height ...
	);
	[rROI, cROI] = find(region.mask == 1);
	ROI = frame(min(rROI):max(rROI), min(cROI):max(cROI));
end

function [xbar, ybar] = get_centroid(ROI)
% This code calculates the intensity-weighted centroid of the input ROi. 
% 
% Miran Oh
% 08-04-2017

    [n_rows, n_columns] = size(ROI);
    [X_mesh, Y_mesh] = meshgrid(1:n_columns, 1:n_rows);
        
    xbar = sum(sum(X_mesh.*double(ROI))) / sum(sum(double(ROI)));
    ybar = sum(sum(Y_mesh.*double(ROI))) / sum(sum(double(ROI)));
end

function OBJ = get_Obj(ROI)
% This code generates a binary matrix of all of the connected objects in
% the input matrix. 
% 
% Miran Oh
% 02-08-2018

    Z = double(ROI-mean2(ROI))/double(std2(ROI)); %no abs (we want brighter intensities than mean, not darker ones)

    BW = Z > 0.8225; %binary matrix to get connected components (with confidence interval of 95% (one-sided) (90%: 0.64))

    CC=bwconncomp(BW); %get connected objects (flood-fill algorithm)
    
    if CC.NumObjects == 0
        BW = Z > 0.64;  % confidence interval of 90% (one-sided)
        noObj = sprintf('CI of 90 percent is used.');
        disp(noObj);
    end
    
    bw = BW;
    CC=bwconncomp(BW);
    for i = 1:CC.NumObjects % get binary matrix for each object
        for j = 1:CC.NumObjects
            if ~isequal(i, j)
                bw(CC.PixelIdxList{j}) = 0;
            end
        end
        OBJ{i} = bw;
        bw = BW;
    end
end