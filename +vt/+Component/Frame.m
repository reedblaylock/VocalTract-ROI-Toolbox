classdef Frame < vt.Component %& vt.Action.Dispatcher
	properties
% 		actionType = @vt.Action.NotifyFrameClick
		imageHandle
% 		isEditing = ''
	end
	
	methods
		function this = Frame(parent)
			p = vt.InputParser;
			p.addParent();
			p.parse(parent);
			
			this.handle = axes('Parent', p.Results.parent.handle);
			this.imageHandle = imagesc([], 'Parent', this.handle);
			axis image;
			colormap gray;
			
% 			this.setCallback('ButtonDownFcn');
% 			set( ...
% 				this.imageHandle, ...
% 				'ButtonDownFcn', ...
% 				@(source, eventdata) processClick(this, source, eventdata) ...
% 			);
		end
		
		function [] = update(this, frame)
			% Use imshow?
			this.imageHandle.CData = frame;
% 			imagesc(frame, 'Parent', this.handle);
% 			axis image;
% 			colormap gray;
		end
		
% 		function [] = processClick(this, ~, ~)
% 			disp('Processing click!');
% 			coordinates = get(this.handle, 'CurrentPoint');
% 			coordinates = round(coordinates(1, 1:2)) - .5;
% 			
% 			if(this.showOrigin)
% 				this.drawOrigin(coordinates);
% 			end
% 			if(this.showOutline)
% 				this.drawOutline(coordinates);
% 			end
% 			if(this.showFill)
% 				this.drawFill(coordinates);
% 			end
% 		end
		
		function [] = drawOrigin(this, regionName, coordinates, color)
			p = inputParser;
			p.addRequired('regionName', @ischar);
			p.addRequired('coordinates', @isnumeric);
			p.addRequired('color', @(color) (isnumeric(color) || ischar(color)));
			parse(p, regionName, coordinates, color);
			
% 			this.deleteOrigin(regionName);
			rectangle('Parent', this.handle, 'Position', [coordinates(:)', 1, 1], 'EdgeColor', 'black', 'FaceColor', color, 'Tag', regionName);
			
			disp(['Drawing ' regionName '...']);
		end
		
		function [] = deleteOrigin(this, regionName)
			oldOrigin = findobj('Type', 'rectangle', 'Tag', regionName, 'Parent', this.handle);
			delete(oldOrigin);
			
			disp(['Deleting ' regionName '...']);
		end
		
		function [] = drawOutline(this, regionName, mask, color)
% 			this.deleteOutline(regionName);
			% horizontal lines
			idxs = find(any(mask));
			for a = 1:length(idxs)
				min_c = find(any(mask(:,idxs(a)),2), 1 );
				max_c = find(any(mask(:,idxs(a)),2), 1, 'last' );
				x = [idxs(a)-.5, idxs(a)+.5];
				y1 = [min_c - .5, min_c - .5];
				y2 = [max_c + .5, max_c + .5];
% 				line([x x], [y1 y2], 'Color', color, 'Parent', this.handle, 'Tag', regionName);
				line(x,y1,'Color',color, 'Tag', regionName);
				line(x,y2,'Color',color, 'Tag', regionName);
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
				line(x1,y,'Color',color, 'Tag', regionName, 'Parent', this.handle);
				line(x2,y,'Color',color, 'Tag', regionName, 'Parent', this.handle);
			end
		end
		
		function [] = deleteOutline(this, regionName)
			oldOutline = findobj('Type', 'line', 'Tag', regionName, 'Parent', this.handle);
			delete(oldOutline);
		end
		
		function [] = renameAll(this, oldName, newName)
			objs = findobj('Parent', this.handle, 'Tag', oldName);
			set(objs, 'Tag', newName);
		end
		
% 		function [] = dispatchAction(this, ~, ~)
% 			coordinates = get(this.handle, 'CurrentPoint');
% 			data.coordinates = coordinates(1, 1:2);
% 			data.isEditing = this.isEditing;
% 			this.action.dispatch(data);
% 		end
	end
	
end

