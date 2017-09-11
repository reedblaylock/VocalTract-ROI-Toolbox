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
			
			% TODO: These assignment should be caused by a separate event
			timeseries = struct();
			timeseries.id = this.state.regionIdCounter;
			timeseries.data = [];
			this.state.currentTimeseries = timeseries;
			this.state.currentRegion = region;
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
			
			% TODO: These assignment should be caused by a separate event
			this.state.currentTimeseries = struct('id', [], 'data', []);
			this.state.currentRegion = region;
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
			
			% TODO: get this out of here as well
			this.state.currentTimeseries.data = mean(this.state.video.matrix(:,mask>0),2);
			this.state.currentRegion.mask = mask;
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
				this.state.timeseries = this.state.currentTimeseries;
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
				this.state.timeseries(idx) = this.state.currentTimeseries;
				this.state.regions(idx) = this.state.currentRegion;
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
				this.state.timeseries(idx) = [];
				this.state.regions(idx) = [];
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
					this.state.currentTimeseries = this.state.timeseries(iRegion);
					this.state.currentRegion = this.state.regions(iRegion);
					return;
				end
			end
			
			% TODO: This should be a separate action
			this.clearCurrentRegion(source, eventData);
		end
		
		function [] = copy(this, source, eventData)
			% Select which files to copy to via the file select UI
			fileSelector = vt.FileSelector();
			[filenames, fullpaths] = fileSelector.selectMultiFile('avi');
			
			% For each of the files selected...
			for iFile = 1:numel(filenames)
				filename = filenames{iFile};
				fullpath = fullpaths{iFile};
				
				disp(['Copying regions to ' filename '...']);
				
				% - Load the appropriate video
				videoLoader = vt.Video.Loader;
				video = videoLoader.loadVideo(filename, fullpath);
				
				% - Check the file to make sure the frame size is the same
				if(video.height ~= this.state.video.height)
					this.log.exception('When copying region information, videos must have the same height.');
					return;
				end
				if(video.width ~= this.state.video.width)
					this.log.exception('When copying region information, videos must have the same width.');
					return;
				end
				
				% - Apply regions to the appropriate positions
				regions = this.state.regions;
				
				% - Re-take timeseries
				timeseries = this.state.timeseries; % copy, not reference
				for iTimeseries = 1:numel(timeseries)
					currentTimeseries = timeseries(iTimeseries);
					idx = find([regions.id] == currentTimeseries.id);
					currentRegion = regions(idx);
					
					timeseries(iTimeseries).data = mean(video.matrix(:, currentRegion.mask > 0),2);
				end
				
				% - Export
				this.exportData(video, regions, timeseries);
			end
		end
		
		function [] = export(this, ~, ~)
			this.exportData(this.state.video, this.state.regions, this.state.timeseries);
		end
		
		function [] = exportData(this, video, regions, allTimeseries)
			if(isempty(fieldnames(regions)) || ~numel(regions))
				% There are no regions saved right now, so there's nothing to
				% delete
				return;
			end
			
			disp('Exporting timeseries...');
			
			wav_dir = 'wav';
			avi_dir = 'avi';
			velum_upordown = 'down';
			data.fps = video.frameRate;
			
			frames = 0:(video.nFrames-1); % 1 gets added in FormatData.m, so subtract it here (assuming the frames are 1-based instead of 0-based, I suppose)
			times = frames ./ video.frameRate;

% 			regionNames = {regions(:).name};	
			regionIds = [regions(:).id];
			
			for iRegion = 1:length(regionIds)
				regionId = regionIds(iRegion);
				regionIdx = find([regions.id] == regionId);
				region = regions(regionIdx);
				oneTimeseries = allTimeseries(regionIdx);
% 				region = regions(iRegion);
				
				data.gest(iRegion).name = region.name;

% 				p1 = articulator.points(1,:);
% 				p2 = articulator.points(end,:);
% 				pmean = mean([p1; p2], 1);
% 				data.gest(n).location = pmean;
				data.gest(iRegion).location = region.origin;

				data.gest(iRegion).frames = frames;
				data.gest(iRegion).times = times;

				% TODO: Put this filtering somewhere else
				disp(['Smoothing timeseries for region ' region.name '...']);
				interp = 1; % If you make this value bigger, you can interpolate additional points
				wwid = .9;
				X	= 1:size(oneTimeseries.data(:,1));
				Y	= oneTimeseries.data;
				D	= linspace(min(X),max(X),(interp*max(X)))';
				[filtered_timeseries, ~] = lwregress3(X',Y,D,wwid);
				
				if (~isempty(strfind(lower(region.name), 'vel')) && strcmp(velum_upordown, 'down'))
					smooth_ts = filtered_timeseries;
				else
					smooth_ts = max(filtered_timeseries) - filtered_timeseries + min(filtered_timeseries);
				end
				data.gest(iRegion).Ismoothed = smooth_ts;
				data.gest(iRegion).stimes = (D-1) ./ video.frameRate;
			end
			
			filename = video.filename;
			[~, filename, ~] = fileparts(filename); % Make sure you're getting only the file name, not the extension
			data = this.formatData(data, filename, wav_dir, avi_dir);
% 			data = FormatData2(data, filename, wav_dir, avi_dir);
% 			if nargin < 2
% 				data = FormatData2(data, filename);
% 			else
% 				data = FormatData2(data, filename, wav_dir, avi_dir); % This function should be with the other MViewRT function
% 			end

			%%% Save a separate variable with the region and video settings
			state = struct();
			state.video = video;
			state.regions = regions;

			save(filename, 'data', 'state');
			
			disp(['Finished exporting ' filename]);
		end
		
		% TODO: Move this somewhere else
		function d = formatData(~, v, fName, wav_dir, avi_dir)
			%FORMATDATA  - format rtMRI data for use with mviewRT
			%
			%	usage:  d = FormatData(v, fName, locNames)
			%
			% V is the rtMRI intensity data variable
			% FNAME maps to the associated WAV and AVI files
			%
			% optional LOCNAMES identifies the pixel intensity regions
			% (drawn from V.gest(n).name by default)

			% mkt 11/12
			% edited by Reed Blaylock 9/2015, 8/2017

			locNames = {v.gest.name};

			audio_name = [fName '.wav'];
			if nargin > 2
				audio_name = fullfile(wav_dir, audio_name);
			end

			video_name = [fName '.avi'];
			if nargin > 3
				video_name = fullfile(avi_dir, video_name);
			end

			% load audio
			try
				if exist('audioread', 'file'), [s,sr] = audioread(audio_name); else [s,sr] = wavread(audio_name); end
			catch
				error('unable to load WAV file %s',audio_name);
			end
			ht = floor(v.gest(1).times*sr) + 1;
			s = s(ht(1):ht(end));
			d = struct('NAME','AUDIO','SRATE',sr,'SIGNAL',s,'LOCATION',[]);

			% load images
            % TODO: You've already done this to load the video in the first
            % place, so just copy the video frames over...
			try
				h = VideoReader(video_name);
			catch
				error('unable to load AVI file %s',video_name);
			end
			frames = v.gest(1).frames + 1;		% 0- to 1-based
			try
				nfr = get(h,'numberOfFrames');
				img = read(h,frames([1 end]));
			catch
				error('unable to load frames %d:%d in %s (%d frames available)', frames, fn, nfr);
			end
			img = squeeze(img(:,:,1,:));
			d(end+1) = struct('NAME','IMAGE','SRATE',v.fps,'SIGNAL',img,'LOCATION',[]);

			% format output
			gsr = 1 / mean(diff(v.gest(1).stimes));
			for k = 1 : length(v.gest),
				d(end+1) = struct('NAME', locNames{k}, ...
							'SRATE', gsr, ...
							'SIGNAL', v.gest(k).Ismoothed, ...
							'LOCATION',v.gest(k).location);
			end
		end
	end
	
end

