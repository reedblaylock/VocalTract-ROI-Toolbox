classdef ChangeRegionParameter < redux.Action
	events
		CHANGE_REGION_PARAMETER
	end
	
	properties
		region
		parameter
		value
	end
	
	methods
		function [] = prepare(this, region, parameter, value, varargin)
			p = inputParser;
			p.StructExpand = false;
			addRequired(p, 'region');
			addRequired(p, 'parameter');
% 			addOptional(p, 'value', []);
			addRequired(p, 'value');
			addOptional(p, 'video', []);
			parse(p, region, parameter, value, varargin{:});
			
			region = p.Results.region;
			parameter = p.Results.parameter;
			value = p.Results.value;
			video = p.Results.video;
			
			switch(parameter)
				% Parameter/value sets
				case {'origin', 'shape', 'type', 'radius', 'width', 'height', 'minPixels'}
					region.(parameter) = value;
					
					if ~isempty(region.origin)
						region.mask = getMask(region, video);
						switch lower(region.type)
							case 'average'
								region.timeseries = mean(video.matrix(:, region.mask > 0), 2);
							case 'binary'
% 								norm_matrix = (video.matrix - min(video.matrix(:))) / (max(video.matrix(:)) - min(video.matrix(:)));
% 								norm_mean = mean(norm_matrix(:, region.mask > 0), 2);
% 								norm_mean(norm_mean > 0.5) = 1;
% 								norm_mean(norm_mean <= 0.5) = 0;
% 								region.timeseries = norm_mean;
								
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
								region.timeseries = binary_norm;
							otherwise
								error('Invalid region type (vt.Action.ChangeRegionParameter.m)');
						end
						
					end
				case {'color', 'name', 'showOrigin', 'showOutline', 'showFill'}
					region.(parameter) = value;
% 				% Toggles
% 				case {'showOrigin', 'showOutline', 'showFill'}
% 					region.(parameter) = ~region.(parameter);
				otherwise
					% TODO: throw error
			end
			
			this.region = region;
			this.parameter = parameter;
			this.value = value;
		end
	end
end

function mask = getMask(region, video)
	mask = [];
	
	if(isempty(region.origin))
		return;
	end

	shape = region.shape;
	switch(shape)
		case 'Circle'
			mask = find_region(video.matrix, region.origin, region.radius);
		case 'Rectangle'
			mask = find_rectangle_region(video.matrix, region.origin, region.width, region.height);
		otherwise
			% TODO: error, this shape has not been programmed
	end
end

function mask = find_region(vidMatrix, pixloc, radius)		
% 			Adam Lammert (2010)

	fheight = sqrt(size(vidMatrix,2));
	fwidth = sqrt(size(vidMatrix,2));

	% Neighbors
	[N] = pixelneighbors([fheight fwidth], pixloc, radius);

	% iteratively determine the region
	mask = zeros(fwidth,fheight);
	for itor = 1:size(N,1)
		mask(N(itor,1),N(itor,2)) = 1;
	end
end

function mask = find_rectangle_region(vidMatrix, origin, width, height)
	c = origin(1);
	r = origin(2);
	num_rows = height;
	num_columns = width;

	r1 = r + 1 - ceil(num_rows/2);
	r2 = r1 + num_rows - 1;
	c1 = c + 1 - ceil(num_columns/2);
	c2 = c1 + num_columns - 1;

	fheight = sqrt(size(vidMatrix,2));
	fwidth = sqrt(size(vidMatrix,2));

	% iteratively determine the region
	mask = zeros(fwidth,fheight);
	for i = r1:r2
		for j = c1:c2
			mask(i, j) = 1;
		end
	end
end

function N = pixelneighbors(siz, pixloc, radius)
% 			Adam Lammert (2010)

	%Parameters
% 			fheight = siz(1);
% 			fwidth = siz(2);

	j = pixloc(1);
	i = pixloc(2);

	%Build Distance Map
% 			D = zeros(fheight,fwidth);
	D1 = repmat((1:siz(1))',1,siz(2));
	D2 = repmat((1:siz(2)),siz(2),1);
	E1 = repmat(i,siz(2),siz(1));
	E2 = repmat(j,siz(1),siz(2));
	D = sqrt((D1-E1).^2+(D2-E2).^2);

	%Pixels Less than Maximum Distance
	ind = find(D <= radius);
	[y, x] = ind2sub(siz,ind);

	%Build Output
	N = [y x];
end