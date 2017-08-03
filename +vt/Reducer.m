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
			disp('Reducer: setVideo()');
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
			region.type = 'average'; % what kind of timeseries do you want?
			
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
		end
		
		function [] = changeCurrentRegionOrigin(this, ~, eventData)
			this.state.currentRegion.origin = eventData.data;
		end
		
		function [] = changeRegionName(this, ~, eventData)
			this.state.currentRegion.name = eventData.data;
		end
		
		function [] = changeRegionColor(this, ~, eventData)
			this.state.currentRegion.color = eventData.data;
		end
		
		function [] = changeRegionShape(this, ~, eventData)
			this.state.currentRegion.shape = eventData.data;
		end
		
		function [] = changeRegionRadius(this, ~, eventData)
			this.state.currentRegion.radius = eventData.data;
		end
		
		function [] = changeRegionWidth(this, ~, eventData)
			this.state.currentRegion.width = eventData.data;
		end
		
		function [] = changeRegionHeight(this, ~, eventData)
			this.state.currentRegion.height = eventData.data;
		end
		
		function [] = toggleShowOrigin(this, ~, eventData)
			this.state.currentRegion.showOrigin = eventData.data;
		end
		
		function [] = toggleShowOutline(this, ~, eventData)
			this.state.currentRegion.showOutline = eventData.data;
		end
		
		function [] = cancelRegionChange(this, ~, ~)
			this.state.isEditing = '';
		end
		
		function [] = saveRegion(this, ~, ~)
% 			idx = strcmp([this.state.regions.name], this.state.currentRegion.name) && ...
% 				[this.state.regions.origin] == this.state.currentRegion.origin; %#ok<BDSCA>
			
			% TODO: This should be caused by a different action
			this.state.isEditing = '';

			if(isempty(fieldnames(this.state.regions)) || ~numel(this.state.regions))
				% There are no regions saved right now
				this.state.regions = this.state.currentRegion;
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
			end
		end
		
		function [] = deleteRegion(this, ~, ~)
% 			idx = strcmp([this.state.regions.name], eventData.data.name) && ...
% 				[this.state.regions.origin] == eventData.data.origin; %#ok<BDSCA>
			
			% TODO: This should come from a separate action
			this.isEditing = '';

			if(isempty(fieldnames(this.state.regions)) || ~numel(this.state.regions))
				% There are no regions saved right now, so there's nothing to
				% delete
				return;
			end
			
% 			idx = find([this.state.regions.id] == eventData.data);
			idx = find([this.state.regions.id] == this.state.currentRegion.id);
			if(~isempty(idx))
				this.state.regions(idx) = [];
			end
		end
	end
	
end

