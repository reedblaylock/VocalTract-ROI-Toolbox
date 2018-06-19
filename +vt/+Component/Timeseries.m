classdef Timeseries < vt.Component & vt.State.Listener
	properties
		currentFrameNoLine = []
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

			xlim = [1 length(p.Results.data)];
			if xlim(2) <= xlim(1)
				xlim(1) = 0;
			end
			ylim = [min(p.Results.data)-1, max(p.Results.data)+1];
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
		
		function [] = onCurrentFrameNoChange(this, state)
			set(this.currentFrameNoLine, ...
				'XData', [state.currentFrameNo, state.currentFrameNo] ...
			);
		end
	end
	
end

