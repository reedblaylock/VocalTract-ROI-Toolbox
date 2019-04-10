classdef Timeseries < redux.Component
	properties
		currentFrameNoLine = []
		lineLabel
	end
	
	methods
		function this = Timeseries(parent, data, color, currentFrameNo, varargin)
			p = redux.InputParser;
			p.KeepUnmatched = true;
			p.addParent();
			p.addRequired('data', @isnumeric)
			p.addRequired('color', @(color) (ischar(color) || isnumeric(color)));
			p.addRequired('currentFrameNo', @isnumeric);
			p.parse(parent, data, color, currentFrameNo, varargin{:});
			
			this.handle = axes('Parent', p.Results.parent.handle);
			
			this.renderTimeseries(p.Results.data, p.Results.color, p.Results.currentFrameNo, varargin{:});
		end
		
		function [] = renderTimeseries(this, data, color, currentFrameNo, varargin)
			p = redux.InputParser;
			p.KeepUnmatched = true;
			p.addRequired('data', @isnumeric)
			p.addRequired('color', @(color) (ischar(color) || isnumeric(color)));
			p.addRequired('currentFrameNo', @isnumeric);
			p.addParameter('Title', '', @ischar);
			p.parse(data, color, currentFrameNo, varargin{:});
			
			if isempty(p.Results.data)
				return
			end
			
			if size(p.Results.data, 2) == 2
				data = p.Results.data(:, 2);
				% flip the data
				data = max(data) - data + min(data);
				
% 				% Get distance between consecutive points
% 				% https://www.mathworks.com/matlabcentral/answers/323030-how-to-find-distance-between-consecutive-points
% 				data = sqrt( sum( abs( diff( p.Results.data ) ).^2, 2 ) );
% 				% TODO: hack to get the right number of frames
% 				data(end+1) = data(end);
			else
				data = p.Results.data;
			end
			
			plot( ...
				data, ...
				'Parent', this.handle, ...
				'Color', p.Results.color ...
			);

			xlim = [1 length(data)];
			if xlim(2) <= xlim(1)
				xlim(1) = 0;
			end
			ylim = [min(data)-1, max(data)+1];
			this.setParameters( ...
				'XLim', xlim, ...
				'YLim', ylim ...
			);
			
			if(isfield(p.Results, 'Title') && ~isempty(p.Results.Title))
				title(this.handle, p.Results.Title);
			end
			
			if isempty(this.currentFrameNoLine)
				this.currentFrameNoLine = line( ...
					'Parent', this.handle, ...
					'XData', [currentFrameNo, currentFrameNo], ...
					'YData', ylim ...
				);
			else
				set(this.currentFrameNoLine, 'YData', ylim);
				set(this.currentFrameNoLine, ...
					'XData', [currentFrameNo, currentFrameNo] ...
				);
			end
	
			if(numel(fieldnames(p.Unmatched)))
				this.setParameters(p.Unmatched);
			end
		end
		
		function [] = updateFrameNoLine(currentFrameNo)
			set(this.currentFrameNoLine, ...
				'XData', [currentFrameNo, currentFrameNo] ...
			);
		end
	end
	
end

