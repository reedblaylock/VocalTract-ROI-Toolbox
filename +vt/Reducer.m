classdef Reducer < vt.Listener & vt.State.Setter
	% This is where all your reducers go.
	% Actions are dispatched by emitting events from various classes. Those
	% action-events are registered here in the Reducer. Each action-event
	% gets its own reducer.
	%
	% Right now, it seems like every reducer has to know the overall
	% structure of the state; it would be nice if a reducer only had to
	% get/set a small portion of state.
	
	properties
		state
	end
	
	methods
		function this = Reducer(state)
			this.state = state;
		end
	end
	
	methods
		function [] = increment(this, ~, eventData)
			if(isempty(this.state.currentFrameNo))
				return
			end
			
			newFrameNo = this.state.currentFrameNo + eventData.data;
			if(newFrameNo > this.state.video.nFrames), newFrameNo = this.state.video.nFrames; end
			if(newFrameNo < 1), newFrameNo = 1; end
			this.state.currentFrameNo = newFrameNo;
		end
		
		function [] = setCurrentFrameNo(this, ~, eventData)
			newFrameNo = eventData.data;
			if(newFrameNo > this.state.video.nFrames), newFrameNo = this.state.video.nFrames; end
			if(newFrameNo < 1), newFrameNo = 1; end
			this.state.currentFrameNo = newFrameNo;
		end
		
		function [] = setVideo(this, ~, eventData)
			this.state.video = eventData.data;
		end
		
		function [] = setFrameType(this, ~, eventData)
			this.state.frameType = eventData.data;
		end
		
		function [] = newRegion(this, ~, ~)
			this.state.isEditing = 'region';
			
			% TODO: This assignment should be caused by a separate event
			this.state.regionIdCounter = this.state.regionIdCounter + 1;
			
			region = struct();
			region.id = this.state.regionIdCounter;
			
			% TODO: All these defaults should be loaded in from a preferences file
			region.name = '';
% 			region.isSaved = false; % is the region part of vt.State.regions
			region.origin = []; % origin pixel of the region
			region.type = 'Average'; % what kind of timeseries do you want?
			
			% Region shapes and shape parameters
			region.shape = 'Circle'; % region shape
			region.radius = 3; % radius of the region; type='circle'
			region.height = 3; % height of the region; type='rectangle'
			region.width = 3; % width of the region; type='rectangle'
			region.minPixels = 5; % minimum number of pixels required for a valid region; type='statistically-generated'
			region.tau = .6; % type='statistically-generated'
			region.searchRadius = 1; % how far away from click location to look for regions; type='statistically-generated'
			region.mask = []; % a binary matrix, where 1 represents a pixel within the region
			
			% Region appearance
			region.color = 'red'; % region color
			region.showOrigin = 1; % connected to the "Show origin" checkbox
			region.showOutline = 1; % connected to the "Show outline" checkbox
			region.showFill = 0; % connected to the "Show fill" checkbox
			
			% TODO: This assignment should be caused by a separate event
			this.state.currentRegion = region;
			
			timeseries = struct();
			timeseries.id = this.state.regionIdCounter;
			timeseries.data = [];
			this.state.currentTimeseries = timeseries;
		end
		
		function [] = clearCurrentRegion(this, ~, ~)
			region = struct();
			region.id = [];
			
			% TODO: All these defaults should be loaded in from a preferences file
			region.name = '';
% 			region.isSaved = false; % is the region part of vt.State.regions
			region.origin = []; % origin pixel of the region
			region.type = 'Average'; % what kind of timeseries do you want?
			
			% Region shapes and shape parameters
			region.shape = 'Circle'; % region shape
			region.radius = []; % radius of the region; type='circle'
			region.height = []; % height of the region; type='rectangle'
			region.width = []; % width of the region; type='rectangle'
			region.minPixels = []; % minimum number of pixels required for a valid region; type='statistically-generated'
			region.tau = []; % type='statistically-generated'
			region.searchRadius = []; % how far away from click location to look for regions; type='statistically-generated'
			region.mask = []; % a binary matrix, where 1 represents a pixel within the region
			
			% Region appearance
			region.color = 'red'; % region color
			region.showOrigin = 0; % connected to the "Show origin" checkbox
			region.showOutline = 0; % connected to the "Show outline" checkbox
			region.showFill = 0; % connected to the "Show fill" checkbox
			
			% TODO: This assignment should be caused by a separate event
			this.state.currentRegion = region;
			this.timeseries.currentTimeseries = struct('id', [], 'data', []);
		end
		
		function [] = editRegion(this, ~, ~)
			this.state.isEditing = 'region';
		end
		
		function [] = changeCurrentRegionOrigin(this, ~, eventData)
			this.state.currentRegion.origin = eventData.data;
			this.changeMask();
		end
		
		function [] = changeMask(this)
			% Set the mask as well
			% TODO: Get this logic out of here
			if(isempty(this.state.currentRegion.origin))
				return;
			end
			
			shape = this.state.currentRegion.shape;
			switch(shape)
				case 'Circle'
					mask = this.find_region(this.state.video.matrix, this.state.currentRegion.origin, this.state.currentRegion.radius);
				case 'Rectangle'
					mask = this.find_rectangle_region(this.state.video.matrix, this.state.currentRegion.origin, this.state.currentRegion.width, this.state.currentRegion.height);
				otherwise
					% TODO: error, this shape has not been programmed
			end
			this.state.currentRegion.mask = mask;
			
			% TODO: get this out of here as well
			this.state.currentTimeseries.data = mean(this.state.video.matrix(:,this.state.currentRegion.mask>0),2);
		end
		
		function mask = find_region(this, vidMatrix, pixloc, radius)		
% 			Adam Lammert (2010)

			fheight = sqrt(size(vidMatrix,2));
			fwidth = sqrt(size(vidMatrix,2));
			
			% Neighbors
			[N] = this.pixelneighbors([fheight fwidth], pixloc, radius);

			% iteratively determine the region
			mask = zeros(fwidth,fheight);
			for itor = 1:size(N,1)
				mask(N(itor,1),N(itor,2)) = 1;
			end
		end
		
		function mask = find_rectangle_region(~, vidMatrix, origin, width, height)
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
		
		function N = pixelneighbors(~, siz, pixloc, radius)
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
		
		function [] = changeRegionName(this, ~, eventData)
			this.state.currentRegion.name = eventData.data;
		end
		
		function [] = changeRegionColor(this, ~, eventData)
			this.state.currentRegion.color = eventData.data;
		end
		
		function [] = changeRegionShape(this, ~, eventData)
			this.state.currentRegion.shape = eventData.data;
			this.changeMask();
		end
		
		function [] = changeRegionRadius(this, ~, eventData)
			this.state.currentRegion.radius = eventData.data;
			this.changeMask();
		end
		
		function [] = changeRegionWidth(this, ~, eventData)
			this.state.currentRegion.width = eventData.data;
			this.changeMask();
		end
		
		function [] = changeRegionHeight(this, ~, eventData)
			this.state.currentRegion.height = eventData.data;
			this.changeMask();
		end
		
		function [] = toggleShowOrigin(this, ~, eventData)
			this.state.currentRegion.showOrigin = eventData.data;
		end
		
		function [] = toggleShowOutline(this, ~, eventData)
			this.state.currentRegion.showOutline = eventData.data;
		end
		
		function [] = cancelRegionChange(this, source, eventData)
			this.state.isEditing = '';
			
			% TODO: If the canceled region wasn't saved, clear
			% state.currentRegion
			% TODO: This should be a separate action
			this.clearCurrentRegion(source, eventData);
		end
		
		function [] = saveRegion(this, ~, ~)
% 			idx = strcmp([this.state.regions.name], this.state.currentRegion.name) && ...
% 				[this.state.regions.origin] == this.state.currentRegion.origin; %#ok<BDSCA>
			
			% TODO: This should be caused by a different action
			this.state.isEditing = '';

			if(isempty(fieldnames(this.state.regions)) || ~numel(this.state.regions))
				% There are no regions saved right now
				this.state.regions = this.state.currentRegion;
				this.state.timeseries = this.state.currentTimeseries;
			else
				% There are regions saved right now. See if any of them have the
				% currentRegion's id
				idx = find([this.state.regions.id] == this.state.currentRegion.id);
				
				if(isempty(idx))
					% None of the saved regions have this region's id. Add
					% currentRegion to the end of the structure
					idx = numel(this.state.regions) + 1;
				end
				this.state.regions(idx) = this.state.currentRegion;
				this.state.timeseries(idx) = this.state.currentTimeseries;
			end
		end
		
		function [] = deleteRegion(this, source, eventData)
% 			idx = strcmp([this.state.regions.name], eventData.data.name) && ...
% 				[this.state.regions.origin] == eventData.data.origin; %#ok<BDSCA>
			
			% TODO: This should come from a separate action
			this.state.isEditing = '';

			if(isempty(fieldnames(this.state.regions)) || ~numel(this.state.regions))
				% There are no regions saved right now, so there's nothing to
				% delete
				return;
			end
			
% 			idx = find([this.state.regions.id] == eventData.data);
			idx = find([this.state.regions.id] == this.state.currentRegion.id);
			if(~isempty(idx))
				this.state.regions(idx) = [];
				this.state.timeseries(idx) = [];
			end
			
			% TODO: This should be a separate action
			this.clearCurrentRegion(source, eventData);
		end
		
		function [] = setCurrentRegion(this, source, eventData)
			if(isempty(fieldnames(this.state.regions)) || ~numel(this.state.regions))
				% There are no regions saved right now, so there's nothing to
				% delete
				return;
			end
			
			% TODO: For overlapping regions, pick the region based on some
			% algorithm
			coordinates = eventData.data;
			coordinates = fliplr(coordinates);
			for iRegion = 1:numel(this.state.regions)
				mask = this.state.regions(iRegion).mask;
				if(mask(coordinates(1), coordinates(2)))
					this.state.currentRegion = this.state.regions(iRegion);
					this.state.currentTimeseries = this.state.timeseries(iRegion);
					return;
				end
			end
			
			% TODO: This should be a separate action
			this.clearCurrentRegion(source, eventData);
		end
	end
	
end

