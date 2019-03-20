% This class is a wrapper for redux.Component.Frame, providing the logic required
% to make appropriate updates to the frame's visualization.
classdef Frame < redux.Component.Wrapper & redux.State.Listener & redux.Action.Dispatcher
	properties
		regions
		video
		
		% An object of type redux.Component.Frame
		frame
		
		% The current value for isEditing, given by State.
		isEditing = ''
		
		% The parameters of the current region.
		currentRegion
	end
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Store a redux.Component.Frame object, and register a callback function
		% (see redux.Component and redux.Action.Dispatcher).
		function this = Frame(frame)
			p = redux.InputParser;
			p.addRequired('frame', @(frame) isa(frame, 'vt.Component.Frame'));
			parse(p, frame);
			
			this.frame = p.Results.frame;
			
			this.setCallback();
		end
		
		%%%%% STATE LISTENER %%%%%
		
		% Update the current frame shown. This function is called by
		% redux.State.Listener when the current frame number changes in State.
		function [] = onCurrentFrameNoChange(this, state)
			if ~isempty(state.video) && ~isempty(state.frameType) && ~isempty(state.currentFrameNo)
				this.switchFrameType(state.frameType, state.video, state.currentFrameNo);
			end
		end
		
		% Update the current frame shown. This function is called by
		% redux.State.Listener when the current video changes in State.
		function [] = onVideoChange(this, state)
			this.video = state.video;
			this.switchFrameType(state.frameType, state.video, 1);
		end
		
		% Update the current frame shown. This function is called by
		% redux.State.Listener when the current frame type changes in State.
		function [] = onFrameTypeChange(this, state)
			this.switchFrameType(state.frameType, state.video, state.currentFrameNo);
		end
		
		% Prepare to add/edit a region, or redraw all regions. This function is 
		% called by redux.State.Listener when the current value for isEditing 
		% changes in State.
		function [] = onIsEditingChange(this, state)
			this.isEditing = state.isEditing;
% 			switch(state.isEditing)
% 				case 'region'
% % 					this.setCurrentRegionDefaults();
% 				otherwise
% 					this.deleteCurrentRegion(state);
% 					this.redrawAllRegions(state);
% 			end
		end
		
		% Update the visual display of the current region. Update the
		% currentRegion property. This function is called by State.Listener
		% whenever a value of the current region changes in State.
		function [] = onCurrentRegionChange(this, state)
			if isempty(state.currentRegion)
				this.currentRegion = [];
			else
				for iRegion = 1:numel(state.regions)
					if state.regions{iRegion}.id == state.currentRegion
						this.currentRegion = state.regions{iRegion};
						break;
					end
				end
			end
			
% 			if(~strcmp(state.isEditing, 'region'))
% 				return;
% 			end
% 			
% 			if ~isempty(this.currentRegion) && ~isempty(this.currentRegion.mask)
% 				this.deleteCurrentRegion(state);
% 				if(this.currentRegion.showOrigin)
% 					this.frame.drawOrigin(this.currentRegion.id, this.currentRegion.origin, this.currentRegion.color);
% 				end
% 				if(this.currentRegion.showOutline)
% 					this.frame.drawOutline(this.currentRegion.id, this.currentRegion.mask, this.currentRegion.color);
% 				end
% 			end
		end
		
		% Redraw all saved regions. This function is called by State.Listener
		% whenever a saved region is changed in State (i.e. added or deleted).
		function [] = onRegionsChange(this, state)
			this.redrawAllRegions(state);
			
			this.regions = state.regions;
			
			for iRegion = 1:numel(state.regions)
				if state.regions{iRegion}.id == state.currentRegion
					this.currentRegion = state.regions{iRegion};
					break;
				end
			end
			
% 			this.deleteCurrentRegion(state);
		end
		
		%%%%% ACTION DISPATCHER %%%%%
		
		% Overwrite the redux.Action.Dispatcher function dispatchAction to include
		% the current isEditing state and the coordinates that were clicked.
		function [] = dispatchAction(this, ~, ~)
% 			d = struct();
% 			d.isEditing = this.isEditing;
% 			coordinates = this.frame.getParameter('CurrentPoint');
% 			d.coordinates = round(coordinates(1, 1:2));
% 			
% 			this.action.dispatch(d);
			
			coordinates = this.frame.getParameter('CurrentPoint');
			coordinates = round(coordinates(1, 1:2));
			switch(this.isEditing)
				case 'region'
					% We're in region-editing mode, and the frame was clicked.
					% Put down an origin point.
					action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
					action.prepare(this.currentRegion, 'origin', coordinates, this.video);
					action.dispatch();
				otherwise
					% We're not in editing mode, and the frame was clicked.
					% 1. The click location is within a region on the frame, so
					%    set currentRegion = the clicked region
					% 2. The click location is not within a region, so clear the
					%    currentRegion (or, do nothing)
					action = this.actionFactory.actions.SET_CURRENT_REGION();
					action.prepare(coordinates, this.regions);
					action.dispatch();
			end
		end
		
		%%%%% OTHER %%%%%
		
		% Control which frame type will be displayed.
		function [] = switchFrameType(this, frameType, video, currentFrameNo)
			switch(frameType)
				case 'frame'
					this.showFrame(video, currentFrameNo);
				case 'mean'
					this.showMeanImage(video);
				case 'std dev'
					this.showStandardDeviationImage(video);
				otherwise
					% TODO: throw error?
			end
		end
		
		% Force the stored Frame object to render an update.
		function [] = triggerFrameUpdate(this, img)
			this.frame.update(img);
		end
		
		% Display the specified frame of the video.
		function [] = showFrame(this, video, frameNo)
			img = this.getFrame(video, frameNo);
			this.triggerFrameUpdate(img);
		end
		
		% Display the mean image of the video.
		function [] = showMeanImage(this, video)
			img = this.getMeanImage(video);
			this.triggerFrameUpdate(img);
		end
		
		% Display the standard deviation image of the video.
		function [] = showStandardDeviationImage(this, video)
			img = this.getStandardDeviationImage(video);
			this.triggerFrameUpdate(img);
		end
		
		% Find the specified frame of the video.
		function frame = getFrame(~, video, frameNo)
			frame = reshape( ...
				video.matrix(frameNo,:), ...
				video.width, ...
				video.height ...
			);
		end
		
		% Find the mean of the video.
		function meanimage = getMeanImage(~, video)
			meanimage = reshape( ...
				mean(video.matrix, 1), ...
				video.width, ...
				video.height ...
			);
		end
		
		% Find the standard deviation of the video.
		function stdimage = getStandardDeviationImage(~, video)
			stdimage = reshape( ...
				std(video.matrix, 1), ...
				video.width, ...
				video.height ...
			);
		end
		
		% Delete any visualization of the current region.
% 		function [] = deleteCurrentRegion(this, state)
% 			if ~isempty(state.currentRegion)
% 				this.frame.deleteOrigin(state.currentRegion);
% 				this.frame.deleteOutline(state.currentRegion);
% 			end
% 		end
		
		% Redraw all regions stored in State.regions.
		function [] = redrawAllRegions(this, state)
			% Delete regions that are currently visible
			nOldRegions = numel(this.regions);
			for iOldRegion = 1:nOldRegions
				region = this.regions{iOldRegion};
				if ~isempty(region.mask)
					this.frame.deleteOrigin(region.id);
					this.frame.deleteOutline(region.id);
				end
			end
			
			% Draw regions that are in state
			nNewRegions = numel(state.regions);
			for iNewRegion = 1:nNewRegions
				region = state.regions{iNewRegion};
				if ~isempty(region.origin) && region.showOrigin
					this.frame.drawOrigin(region.id, region.origin, region.color);
				end
				if ~isempty(region.mask) && region.showOutline
					this.frame.drawOutline(region.id, region.mask, region.color);
				end
			end
			
% 			if isempty(state.regions) || ~numel(state.regions)
% 				% There are no regions saved right now
% 				return;
% 			end
% 			
% 			nRegions = numel(state.regions);
% 			for iRegion = 1:nRegions
% 				region = state.regions{iRegion};
% 				
% 				if(~isempty(region.mask))
% 					this.frame.deleteOrigin(region.id);
% 					this.frame.deleteOutline(region.id);
% 					if(region.showOrigin)
% 						this.frame.drawOrigin(region.id, region.origin, region.color);
% 					end
% 					if(region.showOutline)
% 						this.frame.drawOutline(region.id, region.mask, region.color);
% 					end
% 				end
% 			end
		end
		
		% Fill this object's currentRegion property with the same defaults found
		% in State.
		function [] = setCurrentRegionDefaults(this)
			config = vt.Config();
			this.currentRegion = config.region;
		end
	end
	
	%%%%% ACTION DISPATCHER %%%%%
	methods (Access = ?redux.Action.Dispatcher)
		% Overwrite the redux.Component function setCallback to use the frame
		% property's image handle (rather than the frame handle).
		function [] = setCallback(this, varargin)
			set( ...
				this.frame.imageHandle, ...
				'ButtonDownFcn', ...
				@(source, eventdata) dispatchAction(this, source, eventdata) ...
			);
		end
	end
	
end

