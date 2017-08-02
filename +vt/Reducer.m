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
			
			% All these defaults should be loaded in from a preferences file
			region = struct();
			region.name = '__tempregion';
			region.isSaved = false; % is the region part of vt.State.regions
			region.origin = []; % origin pixel of the region
			region.type = 'average'; % what kind of timeseries do you want?
			
			% Region shapes and shape parameters
			region.shape = 'circle'; % region shape
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
		
		function [] = toggleShowOrigin(this, ~, eventData)
			this.state.currentRegion.showOrigin = eventData.data;
		end
		
		function [] = toggleShowOutline(this, ~, eventData)
			this.state.currentRegion.showOutline = eventData.data;
		end
		
		function [] = cancelRegionChange(this, ~, ~)
			this.state.isEditing = '';
		end
		
		function [] = delete(~)
			disp('Reducer is being destroyed');
		end
	end
	
end

