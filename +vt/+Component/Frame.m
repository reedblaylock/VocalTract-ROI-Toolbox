classdef Frame < redux.Component
	properties
		imageHandle
	end
	
	methods
		function this = Frame(parent)
			p = redux.InputParser;
			p.addParent();
			p.parse(parent);
			
			this.handle = axes('Parent', p.Results.parent.handle);
			this.imageHandle = imagesc([], 'Parent', this.handle);
			axis image;
% 			colormap gray;
			colormap(this.handle, 'gray');
		end
		
		function [] = update(this, frame)
			% Use imshow?
            set(this.imageHandle, 'CData', frame);
            axis(this.handle, 'image');
            if vt.Config.isOldMatlabVersion()
                set(gca, 'Ydir', 'reverse');
            end
% 			this.imageHandle.CData = frame;
		end
		
		function [] = drawOrigin(this, regionId, coordinates, color)
			p = inputParser;
			p.addRequired('regionId', @isnumeric);
			p.addRequired('coordinates', @isnumeric);
			p.addRequired('color', @(color) (isnumeric(color) || ischar(color)));
			parse(p, regionId, coordinates, color);
			
			regionId = num2str(p.Results.regionId);
			coordinates = p.Results.coordinates - .5;
			rectangle('Parent', this.handle, 'Position', [coordinates(:)', 1, 1], 'EdgeColor', 'black', 'FaceColor', p.Results.color, 'Tag', regionId);
			
% 			disp(['Drawing ' regionId '...']);
		end
		
		function [] = deleteOrigin(this, regionId)
			regionId = num2str(regionId);
			oldOrigin = findobj('Type', 'rectangle', 'Tag', regionId, 'Parent', this.handle);
			delete(oldOrigin);
			
% 			disp(['Deleting ' regionId '...']);
		end
		
		function [] = drawOutline(this, regionId, mask, color)
			regionId = num2str(regionId);
			
			% horizontal lines
			idxs = find(any(mask));
			for a = 1:length(idxs)
				min_c = find(any(mask(:,idxs(a)),2), 1 );
				max_c = find(any(mask(:,idxs(a)),2), 1, 'last' );
				x = [idxs(a)-.5, idxs(a)+.5];
				y1 = [min_c - .5, min_c - .5];
				y2 = [max_c + .5, max_c + .5];
% 				line([x x], [y1 y2], 'Color', color, 'Parent', this.handle, 'Tag', regionName);
				line(x, y1, 'Color', color, 'Tag', regionId, 'Parent', this.handle);
				line(x, y2, 'Color', color, 'Tag', regionId, 'Parent', this.handle);
			end
			% vertical lines
			idxs = find(any(mask,2));
			for a = 1:length(idxs)
				min_r = find(any(mask(idxs(a),:),1), 1 );
				max_r = find(any(mask(idxs(a),:),1), 1, 'last' );
				y = [idxs(a)-.5, idxs(a)+.5];
				x1 = [min_r - .5, min_r - .5];
				x2 = [max_r + .5, max_r + .5];
% 				line([x1 x2], [y y], 'Color', 'red', 'Parent', this.handle);
				line(x1, y, 'Color', color, 'Tag', regionId, 'Parent', this.handle);
				line(x2, y, 'Color', color, 'Tag', regionId, 'Parent', this.handle);
			end
		end
		
		function [] = deleteOutline(this, regionId)
			regionId = num2str(regionId);
			
			oldOutline = findobj('Type', 'line', 'Tag', regionId, 'Parent', this.handle);
			delete(oldOutline);
		end
		
		function [] = drawCentroid(this, coordinates, regionId, mask, color)
			p = inputParser;
			p.addRequired('coordinates', @isnumeric);
			p.addRequired('regionId', @isnumeric);
			p.addRequired('mask', @isnumeric);
			p.addRequired('color', @(color) (isnumeric(color) || ischar(color)));
			parse(p, coordinates, regionId, mask, color);
			
			[y, x] = find(mask > 0, 1, 'first')
			
			regionId = num2str(p.Results.regionId);
% 			coordinates = p.Results.coordinates - .5;
			coordinates = p.Results.coordinates + [x, y] - 0.5
			rectangle('Parent', this.handle, 'Position', [coordinates(1), coordinates(2), 0.5, 0.5], 'FaceColor', p.Results.color, 'Tag', [regionId '-centroid']);
						
% 			hold on;
% 			plot(coordinates(1), coordinates(2), 'Marker', 'o', 'MarkerFaceColor', color, 'Parent', this.handle, 'Tag', [regionId '-centroid']);
% 			hold off;
			
		end
		
		function [] = deleteCentroid(this, regionId)
			regionId = num2str(regionId);
			
			oldCentroid = findobj('Tag', [regionId '-centroid'], 'Parent', this.handle);
			if ~isempty(oldCentroid)
				delete(oldCentroid);
			end
		end
		
% 		function [] = renameAll(this, oldName, newName)
% 			objs = findobj('Parent', this.handle, 'Tag', oldName);
% 			set(objs, 'Tag', newName);
% 		end
	end
	
end

