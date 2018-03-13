classdef NewRegion < vt.Action
	events
		NEW_REGION
	end
	
	properties
		region
	end
	
	methods (Static, Access = private)
		function out = getOrIncrementCount(increment)
			persistent id;
			if isempty(id)
				id = 0;
			end
			if nargin
				id = id + increment;
			end
			out = id;
		end
	end
	
	methods
		function this = NewRegion()
			this.region = struct();
			
			% Increment the counter in the constructor
			this.region.id = NewRegion.getOrIncrementCount(1);
			
			% TODO: All these defaults should be loaded in from a preferences file
			this.region.name = ['Region' num2str(this.region.id)];
% 			region.isSaved = false; % is the region part of vt.State.regions
			this.region.origin = []; % origin pixel of the region
			this.region.type = 'Average'; % what kind of timeseries do you want?
			
			% Region shapes and shape parameters
			this.region.shape = 'Circle'; % region shape
			this.region.radius = 3; % radius of the region; type='circle'
			this.region.height = 3; % height of the region; type='rectangle'
			this.region.width = 3; % width of the region; type='rectangle'
			this.region.minPixels = 5; % minimum number of pixels required for a valid region; type='statistically-generated'
			this.region.tau = .6; % type='statistically-generated'
			this.region.searchRadius = 1; % how far away from click location to look for regions; type='statistically-generated'
			this.region.mask = []; % a binary matrix, where 1 represents a pixel within the region
			
			% Region appearance
			this.region.color = 'red'; % region color
			this.region.showOrigin = 1; % connected to the "Show origin" checkbox
			this.region.showOutline = 1; % connected to the "Show outline" checkbox
			this.region.showFill = 0; % connected to the "Show fill" checkbox
			
			% Timeseries
			this.region.timeseries = [];
		end
	end
end

