classdef Config < redux.Config
	properties
		region
	end
	
	methods
		function this = Config()
			this@redux.Config();
			this.setRegionDefaults();
		end
		
		function [] = setRegionDefaults(this)
			this.region = struct();
			
			this.region.id = [];
			
			this.region.name = ['Region' num2str(this.region.id)];
% 			region.isSaved = false; % is the region part of vt.State.regions
			this.region.origin = []; % origin pixel of the region
			this.region.type = 'Average'; % what kind of timeseries do you want?
			
			% Region shapes and shape parameters
			this.region.shape = 'Circle'; % region shape
			this.region.radius = 3; % radius of the region; type='circle'
			this.region.height = 3; % height of the region; type='rectangle'
			this.region.width = 3; % width of the region; type='rectangle'
			this.region.pixel_minimum = 5; % minimum number of pixels required for a valid region; type='Correlated'
			this.region.tau = .6; % type='Correlated'
			this.region.search_radius = 1; % how far away from click location to look for regions; type='Correlated'
			this.region.mask = []; % a binary matrix, where 1 represents a pixel within the region
			this.region.timeseriesDimension = 'y'; % 'x' or 'y'
			
			% Region appearance
			this.region.color = 'red'; % region color
			this.region.showOrigin = 1; % connected to the "Show origin" checkbox
			this.region.showOutline = 1; % connected to the "Show outline" checkbox
			
			% Timeseries
			this.region.timeseries = [];
		end
	end
end

