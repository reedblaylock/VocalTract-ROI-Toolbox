function mask = getMask(region, video)
	mask = [];
	
	if(isempty(region.origin))
		return;
	end

	shape = region.shape;
	switch(shape)
		case 'Circle'
			mask = find_circle_region(video.matrix, region.origin, region.radius);
		case 'Rectangle'
			mask = find_rectangle_region(video.matrix, region.origin, region.width, region.height);
        case 'Correlated'
            mask = find_correlated_region(video.matrix, region.origin, region.pixel_minimum, region.search_radius, region.tau);
		otherwise
			error(['Shape ' region.shape ' has not been programmed yet.']);
	end
end

function mask = find_circle_region(vidMatrix, pixloc, radius)		
% 	Adam Lammert (2010)

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

function mask = find_correlated_region(vidMatrix, origin, pixel_minimum, search_radius, tau)
    disp('Searching for region...');
% 			
%	Adam Lammert (2010)
%		
%	Correlated Region Analysis with Manual Selection
%		
%	INPUTS:
%	  filename: file name of .avi movie
%	  t: region radius
%	  pixloc: seed pixel location [y x]
%	OUTPUTS:
%	  ts: time series corresp. to the Correlated Region
%	  R: image mask corresp. to the Correlated Region
% 			  

    px = origin(1);
    py = origin(2);
    minx = px - search_radius;
    maxx = px + search_radius;
    miny = py - search_radius;
    maxy = py + search_radius;

    dynamic_range = 0.000;
    x = 0;
    y = 0;
    mask = [];

    for i = minx:maxx
        for j = miny:maxy
            [ts_cra_ij, mask_ij] = correlatedMaskB(vidMatrix, [j i], tau);

            pixelCount = numel(mask_ij( mask_ij(:)>0 ));
            if pixelCount >= pixel_minimum
                filt_range = range(ts_cra_ij);

                if filt_range > dynamic_range
                    dynamic_range = filt_range;
                    mask = mask_ij;
                    x = i;
                    y = j;
                end
            end
        end
    end
    
    if isempty(mask)
        error('Could not find a correlated region with these parameters. Try again!');
    end

    origin = [x y];
    
    disp('Search over!');
end

function [ts, mask] = correlatedMaskB(vidMatrix, pixloc, tau)
% 			
%	Adam Lammert (2010)
%	
%	Correlated Region Analysis with Manual Selection
%	
%	INPUTS:
%     vr: VideoReader object
%	  M: movie matrix
%	  tau: threshold parameter
%	  pixloc: seed pixel location [y x]
%	OUTPUTS:
%	  ts: time series corresp. to the Correlated Region
%	  R: image mask corresp. to the Correlated Region
% 			  

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DETERMINE THE REGION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %frame data
    fheight = sqrt(size(vidMatrix, 2));
    fwidth = sqrt(size(vidMatrix, 2));

    %correlation matrix
    C = corrcoef(vidMatrix);

    %iteratively determine the region
    mask = zeros(fheight, fwidth);

    IDX = sub2ind([fheight fwidth], pixloc(1), pixloc(2));
    im = reshape(C(IDX, :), fheight, fwidth);
    BW = zeros(size(im));
    BW(im>=tau) = 1;

    CN = bwconncomp(BW,4);

    dim = size(CN.PixelIdxList);
    flag = 0;
    count = 0;
    while ((flag == 0) && (count < dim(2)))
        count = count + 1;
        flag = intersect(IDX,CN.PixelIdxList{count});
        if isempty(flag)
            flag=0;
        else
            flag = count;
        end
    end

    mask(CN.PixelIdxList{flag}) = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DETERMINE THE TIME SERIES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ts = mean(vidMatrix(:,mask>0),2);
end

function N = pixelneighbors(siz, pixloc, radius)
% 	Adam Lammert (2010)

%   Parameters
% 	fheight = siz(1);
% 	fwidth = siz(2);

	j = pixloc(1);
	i = pixloc(2);

%   Build Distance Map
% 	D = zeros(fheight,fwidth);
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