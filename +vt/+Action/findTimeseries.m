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
		otherwise
			error('Invalid region type or other error in (vt.Action.findTimeseries.m)');
	end

end

