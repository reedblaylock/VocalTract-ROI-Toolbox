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
			
			data = p.Results.data;
			
% 			% TODO: Put this filtering somewhere else
% 			disp(['Smoothing timeseries...']);
% 			interp = 1; % If you make this value bigger, you can interpolate additional points
% 			wwid = .9;
% 			X = 1:size(data(:,1));
% 			Y = data;
% 			D = linspace(min(X), max(X), (interp*max(X)))';
% 			[filtered_data, ~] = lwregress3(X', Y, D, wwid);
% 			disp('Finished smoothing timeseries');
			
			plot( ...
				data, ...
				'Parent', this.handle, ...
				'Color', p.Results.color ...
			);
		
% 			% plot the filtered data too
% 			hold on;
% 			plot( ...
% 				filtered_data, ...
% 				'Parent', this.handle, ...
% 				'Color', [0.1 0.1 0.1] ...
% 			);
% 			plot( ...
% 				filtfilt(ones(1,5)./5,1,data), ...
% 				'Parent', this.handle, ...
% 				'Color', [0.1 0.1 0.1] ...
% 			);
% 			hold off;

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
		
		function [] = updateFrameNoLine(this, currentFrameNo)
			set(this.currentFrameNoLine, ...
				'XData', [currentFrameNo, currentFrameNo] ...
			);
		end
	end
	
end

