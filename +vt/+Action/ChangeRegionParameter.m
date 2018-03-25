classdef ChangeRegionParameter < vt.Action
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
					
					region.mask = getMask(region, video);
					
					region.timeseries = mean(video.matrix(:, region.mask > 0), 2);
				case {'color', 'showOrigin', 'showOutline', 'showFill'}
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