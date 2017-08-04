classdef Frame < vt.Component.Wrapper & vt.State.Listener & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.NotifyFrameClick
		frame
		isEditing = ''
		currentRegion
	end
	
	methods
		function this = Frame(frame)
			p = inputParser;
			p.addRequired('frame', @(frame) isa(frame, 'vt.Component.Frame'));
			parse(p, frame);
			
			this.frame = p.Results.frame;
			
			this.setCallback();
		end
		
		function [] = triggerFrameUpdate(this, img)
			this.frame.update(img);
		end
		
		% State update methods
		function [] = onCurrentFrameNoChange(this, state)
			switch(state.frameType)
				case 'frame'
					this.showFrame(state.video, state.currentFrameNo);
				case 'mean'
					this.showMeanImage(state.video);
				case 'std dev'
					this.showStandardDeviationImage(state.video);
				otherwise
					% TODO: throw error?
			end
		end
		
		function [] = onVideoChange(this, state)
			switch(state.frameType)
				case 'frame'
					this.showFrame(state.video, 1);
				case 'mean'
					this.showMeanImage(state.video);
				case 'std dev'
					this.showStandardDeviationImage(state.video);
				otherwise
					% TODO: throw error?
			end
		end
		
		function [] = onFrameTypeChange(this, state)
			switch(state.frameType)
				case 'frame'
					this.showFrame(state.video, state.currentFrameNo);
				case 'mean'
					this.showMeanImage(state.video);
				case 'std dev'
					this.showStandardDeviationImage(state.video);
				otherwise
					% TODO: throw error?
			end
		end
		
		function [] = onIsEditingChange(this, state)
			this.isEditing = state.isEditing;
			switch(state.isEditing)
				case 'region'
					% TODO: This should be getting the current region settings from
					% state, to avoid code duplication
					this.setCurrentRegionDefaults(state);
				otherwise
					this.deleteCurrentRegion(state);
					this.redrawAllRegions(state);
			end
		end
		
		function [] = deleteCurrentRegion(this, state)
			if(isfield(state.currentRegion, 'id') && ~isempty(state.currentRegion.id))
				this.frame.deleteOrigin(state.currentRegion.id);
				this.frame.deleteOutline(state.currentRegion.id);
			end
		end
		
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
		
		function [] = onCurrentRegionChange(this, state)
			% Assumption: you cannot change which region you're editing while
			% you're editing a region. If you want to edit a different region,
			% you have to save or cancel your current edits first (clearing
			% state.currentRegion).
			if(~strcmp(state.isEditing, 'region'))
				return;
			end
			
			region = state.currentRegion;
% 			mask = this.getMask(region, state);
			
% 			if(~strcmp(this.currentRegion.name, state.currentRegion.name))
% 				this.frame.renameAll(this.currentRegion.name, state.currentRegion.name);
% 			end
			
			% This will handle changes in color, radius ...
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
			
			this.currentRegion = state.currentRegion;
		end
		
		function [] = onRegionsChange(this, state)
			this.deleteCurrentRegion(state);
			this.redrawAllRegions(state);
		end
		
		function [] = redrawAllRegions(this, state)
			if(isempty(fieldnames(state.regions)) || ~numel(state.regions))
				% There are no regions saved right now
				return;
			end
			
			nRegions = numel(state.regions);
			for iRegion = 1:nRegions
				region = state.regions(iRegion);
% 				mask = this.getMask(region, state);
				
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
		end
		
% 		function mask = getMask(this, region, state)
% 			mask = [];
% 			if(isempty(region.origin))
% 				return;
% 			end
% 			
% 			switch(region.shape)
% 				case 'Circle'
% 					mask = this.find_region(state.video.matrix, region.origin, region.radius);
% 				case 'Rectangle'
% 					mask = this.find_rectangle_region(state.video.matrix, region.origin, region.width, region.height);
% 				otherwise
% 					% TODO: error, this shape has not been programmed
% 			end
% 		end
% 		
% 		function mask = find_region(this, vidMatrix, pixloc, radius)		
% % 			Adam Lammert (2010)
% 
% 			fheight = sqrt(size(vidMatrix,2));
% 			fwidth = sqrt(size(vidMatrix,2));
% 			
% 			% Neighbors
% 			[N] = this.pixelneighbors([fheight fwidth], pixloc, radius);
% 
% 			% iteratively determine the region
% 			mask = zeros(fwidth,fheight);
% 			for itor = 1:size(N,1)
% 				mask(N(itor,1),N(itor,2)) = 1;
% 			end
% 		end
% 		
% 		function mask = find_rectangle_region(~, vidMatrix, origin, width, height)
% 			c = origin(1);
% 			r = origin(2);
% 			num_rows = height;
% 			num_columns = width;
% 			
% 			r1 = r + 1 - ceil(num_rows/2);
% 			r2 = r1 + num_rows - 1;
% 			c1 = c + 1 - ceil(num_columns/2);
% 			c2 = c1 + num_columns - 1;
% 			
% 			fheight = sqrt(size(vidMatrix,2));
% 			fwidth = sqrt(size(vidMatrix,2));
% 			
% 			% iteratively determine the region
% 			mask = zeros(fwidth,fheight);
% 			for i = r1:r2
% 				for j = c1:c2
% 					mask(i, j) = 1;
% 				end
% 			end
% 		end
% 		
% 		function N = pixelneighbors(~, siz, pixloc, radius)
% % 			Adam Lammert (2010)
% 
% 			%Parameters
% % 			fheight = siz(1);
% % 			fwidth = siz(2);
% 			
% 			j = pixloc(1);
% 			i = pixloc(2);
% 
% 			%Build Distance Map
% % 			D = zeros(fheight,fwidth);
% 			D1 = repmat((1:siz(1))',1,siz(2));
% 			D2 = repmat((1:siz(2)),siz(2),1);
% 			E1 = repmat(i,siz(2),siz(1));
% 			E2 = repmat(j,siz(1),siz(2));
% 			D = sqrt((D1-E1).^2+(D2-E2).^2);
% 
% 			%Pixels Less than Maximum Distance
% 			ind = find(D <= radius);
% 			[y, x] = ind2sub(siz,ind);
% 
% 			%Build Output
% 			N = [y x];
% 		end
		
		% Action methods %
		function [] = showFrame(this, video, frameNo)
			img = this.getFrame(video, frameNo);
			this.triggerFrameUpdate(img);
		end
		
		function [] = showMeanImage(this, video)
			img = this.getMeanImage(video);
			this.triggerFrameUpdate(img);
		end
		
		function [] = showStandardDeviationImage(this, video)
			img = this.getStandardDeviationImage(video);
			this.triggerFrameUpdate(img);
		end
		
		% Public helper methods %
		function frame = getFrame(~, video, frameNo)
			frame = reshape( ...
				video.matrix(frameNo,:), ...
				video.width, ...
				video.height ...
			);
		end
		
		function meanimage = getMeanImage(~, video)
			meanimage = reshape( ...
				mean(video.matrix, 1), ...
				video.width, ...
				video.height ...
			);
		end
		
		function stdimage = getStandardDeviationImage(~, video)
			stdimage = reshape( ...
				std(video.matrix, 1), ...
				video.width, ...
				video.height ...
			);
		end
		
		function [] = dispatchAction(this, ~, ~)
			d = struct();
			d.isEditing = this.isEditing;
			coordinates = this.frame.getParameter('CurrentPoint');
			d.coordinates = round(coordinates(1, 1:2));
			
			this.action.dispatch(d);
		end
	end
	
	methods (Access = ?vt.Action.Dispatcher)
		function [] = setCallback(this, varargin)
			set( ...
				this.frame.imageHandle, ...
				'ButtonDownFcn', ...
				@(source, eventdata) dispatchAction(this, source, eventdata) ...
			);
		end
	end
	
end

