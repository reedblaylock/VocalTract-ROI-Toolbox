classdef Timeseries < vt.Component & vt.State.Listener
	properties
		currentFrameNoLine
		lineLabel
	end
	
	methods
		function this = Timeseries(parent, data, color, currentFrameNo, varargin)
			p = vt.InputParser;
			p.KeepUnmatched = true;
			p.addParent();
			p.addRequired('data', @isnumeric)
			p.addRequired('color', @(color) (ischar(color) || isnumeric(color)));
			p.addRequired('currentFrameNo', @isnumeric);
			p.parse(parent, data, color, currentFrameNo, varargin{:});
			
			this.handle = axes('Parent', p.Results.parent.handle);
			
			this.updateTimeseries(p.Results.data, p.Results.color, p.Results.currentFrameNo, varargin{:});
		end
		
		function [] = updateTimeseries(this, data, color, currentFrameNo, varargin)
			p = vt.InputParser;
			p.KeepUnmatched = true;
			p.addRequired('data', @isnumeric)
			p.addRequired('color', @(color) (ischar(color) || isnumeric(color)));
			p.addRequired('currentFrameNo', @isnumeric);
			p.addParameter('Title', '', @ischar);
			p.parse(data, color, currentFrameNo, varargin{:});
			
			if isempty(p.Results.data)
				return
			end
			
			plot( ...
				p.Results.data, ...
				'Parent', this.handle, ...
				'Color', p.Results.color ...
			);
			this.setParameters( ...
				'XLim', [1 length(p.Results.data)], ...
				'YLim', [0 max(p.Results.data)] ...
			);
		
% 			this.vline(p.Results.currentFrameNo);
			
			if(isfield(p.Results, 'Title') && ~isempty(p.Results.Title))
				title(this.handle, p.Results.Title);
			end
			
			if(numel(fieldnames(p.Unmatched)))
				this.setParameters(p.Unmatched);
			end
		end
		
% 		function [] = onCurrentFrameNoChange(this, state)
% 			delete(this.currentFrameNoLine);
% 			delete(this.lineLabel);
% 			this.vline(state.currentFrameNo);
% 		end
		
% 		% https://www.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline
% 		function [] = vline(this, currentFrameNo)
% 			g = ishold(this.handle);
% 			hold on;
% 			
% 			y = this.getParameter('YLim');
% 			this.currentFrameNoLine = plot([currentFrameNo currentFrameNo], y, 'k', 'Parent', this.handle);
% 			
% 			label = num2str(currentFrameNo);
% 			x = currentFrameNo;
% 			xx=get(this.handle,'xlim');
% 			xrange=xx(2)-xx(1);
% 			xunit=(x-xx(1))/xrange;
% 			if xunit<0.8
% 				this.lineLabel = text(x+0.01*xrange,y(1)+0.1*(y(2)-y(1)),label,'color',get(this.handle,'color'), 'Parent', this.handle);
% 			else
% 				this.lineLabel = text(x-.05*xrange,y(1)+0.1*(y(2)-y(1)),label,'color',get(this.handle,'color'), 'Parent', this.handle);
% 			end
% 			
% 			if(g==0)
% 				hold off;
% 			end
% 		end
% 		
% 		function [] = drawOrigin(this, regionId, coordinates, color)
% 			p = inputParser;
% 			p.addRequired('regionId', @isnumeric);
% 			p.addRequired('coordinates', @isnumeric);
% 			p.addRequired('color', @(color) (isnumeric(color) || ischar(color)));
% 			parse(p, regionId, coordinates, color);
% 			
% 			regionId = num2str(p.Results.regionId);
% 			coordinates = p.Results.coordinates - .5;
% 			rectangle('Parent', this.handle, 'Position', [coordinates(:)', 1, 1], 'EdgeColor', 'black', 'FaceColor', p.Results.color, 'Tag', regionId);
% 			
% % 			disp(['Drawing ' regionId '...']);
% 		end
% 		
% 		function [] = deleteOrigin(this, regionId)
% 			regionId = num2str(regionId);
% 			oldOrigin = findobj('Type', 'rectangle', 'Tag', regionId, 'Parent', this.handle);
% 			delete(oldOrigin);
% 			
% % 			disp(['Deleting ' regionId '...']);
% 		end
% 		
% 		function [] = drawOutline(this, regionId, mask, color)
% 			regionId = num2str(regionId);
% 			
% 			% horizontal lines
% 			idxs = find(any(mask));
% 			for a = 1:length(idxs)
% 				min_c = find(any(mask(:,idxs(a)),2), 1 );
% 				max_c = find(any(mask(:,idxs(a)),2), 1, 'last' );
% 				x = [idxs(a)-.5, idxs(a)+.5];
% 				y1 = [min_c - .5, min_c - .5];
% 				y2 = [max_c + .5, max_c + .5];
% % 				line([x x], [y1 y2], 'Color', color, 'Parent', this.handle, 'Tag', regionName);
% 				line(x,y1,'Color',color, 'Tag', regionId);
% 				line(x,y2,'Color',color, 'Tag', regionId);
% 			end
% 			% vertical lines
% 			idxs = find(any(mask,2));
% 			for a = 1:length(idxs)
% 				min_r = find(any(mask(idxs(a),:),1), 1 );
% 				max_r = find(any(mask(idxs(a),:),1), 1, 'last' );
% 				y = [idxs(a)-.5, idxs(a)+.5];
% 				x1 = [min_r - .5, min_r - .5];
% 				x2 = [max_r + .5, max_r + .5];
% % 				line([x1 x2], [y y], 'Color', 'red', 'Parent', this.handle);
% 				line(x1,y,'Color',color, 'Tag', regionId, 'Parent', this.handle);
% 				line(x2,y,'Color',color, 'Tag', regionId, 'Parent', this.handle);
% 			end
% 		end
% 		
% 		function [] = deleteOutline(this, regionId)
% 			regionId = num2str(regionId);
% 			
% 			oldOutline = findobj('Type', 'line', 'Tag', regionId, 'Parent', this.handle);
% 			delete(oldOutline);
% 		end
% 		
% 		function [] = renameAll(this, oldName, newName)
% 			objs = findobj('Parent', this.handle, 'Tag', oldName);
% 			set(objs, 'Tag', newName);
% 		end
	end
	
end

