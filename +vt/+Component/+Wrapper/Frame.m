% This class is a wrapper for vt.Component.Frame, providing the logic required
% to make appropriate updates to the frame's visualization.
classdef Frame < vt.Component.Wrapper & vt.State.Listener & vt.Action.Dispatcher
	properties
		% This object dispatches an action with information about where the
		% frame was clicked.
		actionType = @vt.Action.NotifyFrameClick
		
		% An object of type vt.Component.Frame
		frame
		
		% The current value for isEditing, given by State.
		isEditing = ''
		
		% The parameters of the current region.
		currentRegion
		
		% The list of current midline points
		currentMidline
	end
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Store a vt.Component.Frame object, and register a callback function
		% (see vt.Component and vt.Action.Dispatcher).
		function this = Frame(frame)
			p = vt.InputParser;
			p.addRequired('frame', @(frame) isa(frame, 'vt.Component.Frame'));
			parse(p, frame);
			
			this.frame = p.Results.frame;
			
			this.setCallback();
		end
		
		%%%%% STATE LISTENER %%%%%
		
		% Update the current frame shown. This function is called by
		% vt.State.Listener when the current frame number changes in State.
		function [] = onCurrentFrameNoChange(this, state)
			this.switchFrameType(state.frameType, state.video, state.currentFrameNo);
		end
		
		% Update the current frame shown. This function is called by
		% vt.State.Listener when the current video changes in State.
		function [] = onVideoChange(this, state)
			this.switchFrameType(state.frameType, state.video, 1);
		end
		
		% Update the current frame shown. This function is called by
		% vt.State.Listener when the current frame type changes in State.
		function [] = onFrameTypeChange(this, state)
			this.switchFrameType(state.frameType, state.video, state.currentFrameNo);
		end
		
		% Prepare to add/edit a region, or redraw all regions. This function is 
		% called by vt.State.Listener when the current value for isEditing 
		% changes in State.
		function [] = onIsEditingChange(this, state)
			this.isEditing = state.isEditing;
			switch(state.isEditing)
				case 'region'
					% TODO: This should be getting the current region settings from
					% state, or default preferences, to avoid code duplication
					this.setCurrentRegionDefaults(state);
				case 'midlineNew'
					
				case 'midlineEdit'
					
				otherwise
					this.deleteCurrentRegion(state);
					this.redrawAllRegions(state);
					
					this.deleteMidline(state);
					this.redrawMidline(state);
			end
		end
		
		% Update the visual display of the current region. Update the
		% currentRegion property. This function is called by State.Listener
		% whenever a value of the current region changes in State.
		function [] = onCurrentRegionChange(this, state)
			if(~strcmp(state.isEditing, 'region'))
				return;
			end
			
			region = state.currentRegion;
			
			if(~isempty(region.mask))
				this.deleteCurrentRegion(state);
				if(region.showOrigin)
					this.frame.drawOrigin(region.id, region.origin, region.color);
				end
				if(region.showOutline)
					this.frame.drawOutline(region.id, region.mask, region.color);
				end
			end
			
			this.currentRegion = state.currentRegion;
		end
		
		% Redraw all saved regions. This function is called by State.Listener
		% whenever a saved region is changed in State (i.e. added or deleted).
		function [] = onRegionsChange(this, state)
			this.deleteCurrentRegion(state);
			this.redrawAllRegions(state);
		end
		
		% Redraw midline. This function is called by State.Listener whenever the
		% midline is changed in State (i.e. added, deleted, or changed).
		function [] = onCurrentMidlineChange(this, state)
			this.currentMidline = state.currentMidline;
			this.deleteMidline(state);
			this.redrawMidline(state);
		end
		
		%%%%% ACTION DISPATCHER %%%%%
		
		% Overwrite the vt.Action.Dispatcher function dispatchAction to include
		% the current isEditing state and the coordinates that were clicked.
		function [] = dispatchAction(this, ~, ~)
			d = struct();
			d.isEditing = this.isEditing;
			coordinates = this.frame.getParameter('CurrentPoint');
			d.coordinates = round(coordinates(1, 1:2));
			
			this.action.dispatch(d);
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
		function [] = deleteCurrentRegion(this, state)
			if(isfield(state.currentRegion, 'id') && ~isempty(state.currentRegion.id))
				this.frame.deleteOrigin(state.currentRegion.id);
				this.frame.deleteOutline(state.currentRegion.id);
			end
		end
		
		% Redraw all regions stored in State.regions.
		function [] = redrawAllRegions(this, state)
			if(isempty(fieldnames(state.regions)) || ~numel(state.regions))
				% There are no regions saved right now
				return;
			end
			
			nRegions = numel(state.regions);
			for iRegion = 1:nRegions
				region = state.regions(iRegion);
				
				if(~isempty(region.mask))
					this.frame.deleteOrigin(region.id);
					this.frame.deleteOutline(region.id);
					if(region.showOrigin)
						this.frame.drawOrigin(region.id, region.origin, region.color);
					end
					if(region.showOutline)
						this.frame.drawOutline(region.id, region.mask, region.color);
					end
				end
			end
			
			this.setRegionCallback(region.id);
		end
		
		% Fill this object's currentRegion property with the same defaults found
		% in State.
		function [] = setCurrentRegionDefaults(this, state)
			% TODO: All of this should be given by vt.State
			region = struct();
			region.id = state.regionIdCounter + 1; % In Reducer, the id value is set after the isEditing change. Since this is triggered by onIsEditingChange, you have to increment it explicitly here
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
			region.showOrigin = true; % connected to the "Show origin" checkbox
			region.showOutline = true; % connected to the "Show outline" checkbox
			region.showFill = false; % connected to the "Show fill" checkbox
			
			this.currentRegion = region;
		end
		
		% Delete the visualization of the midline
		function [] = deleteMidline(this, ~)
			this.frame.deleteMidline('midline');
		end
		
		% Redraw the midline defined by state.midline.points
		function [] = redrawMidline(this, state)
			this.frame.drawMidline('midline', state.currentMidline.points, state.currentMidline.color);
			
			this.setMidlineCallback();
		end
		
		function [] = dispatchRectangleAction(this, source, ~)
			position = get(source, 'Position');
			coordinates = position(1, 1:2) + .5;
			
			d = struct();
			d.isEditing = this.isEditing;
			d.coordinates = coordinates;
			if(strcmp(this.isEditing, 'midlineEdit'))
				d.points = this.currentMidline.points;
			end
			
			this.action.dispatch(d);
		end
	end
	
	%%%%% ACTION DISPATCHER %%%%%
	methods (Access = ?vt.Action.Dispatcher)
		% Overwrite the vt.Component function setCallback to use the frame
		% property's image handle (rather than the frame handle).
		function [] = setCallback(this, varargin)
			set( ...
				this.frame.imageHandle, ...
				'ButtonDownFcn', ...
				@(source, eventdata) dispatchAction(this, source, eventdata) ...
			);
		end
		
		function [] = setRegionCallback(this, regionId)
			regionHandles = findobj(this.frame.handle, 'Tag', num2str(regionId), '-and', 'Type', 'rectangle');
			set( ...
				regionHandles, ...
				'ButtonDownFcn', ...
				@(source, eventdata) dispatchRectangleAction(this, source, eventdata) ...
			);
		
% 			regionHandles = findobj(this.frame.handle, 'Tag', num2str(regionId), '-and', 'Type', 'line');
% 			set( ...
% 				regionHandles, ...
% 				'ButtonDownFcn', ...
% 				@(source, eventdata) dispatchLineAction(this, source, eventdata) ...
% 			);
		end
		
		function [] = setMidlineCallback(this)
			midlineHandles = findobj(this.frame.handle, 'Tag', 'midline');
			set( ...
				midlineHandles, ...
				'ButtonDownFcn', ...
				@(source, eventdata) dispatchRectangleAction(this, source, eventdata) ...
			);
		end
	end
	
end

