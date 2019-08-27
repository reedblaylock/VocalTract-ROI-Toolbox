classdef SaveRegions < redux.Action
	events
		SAVE_REGIONS
	end
	
	properties
		regions
		videoName
	end
	
	methods
		function [] = prepare(this, regions, video)
			this.regions = regions;
			[~, fname, ~] = fileparts(video.filename);
			this.videoName = fname;
		end
		
		function [] = dispatch(this)
			for iRegion = 1:numel(this.regions)
				this.regions{iRegion}.timeseries  = [];
			end
			
			[file, path] = uiputfile([this.videoName '_regions.mat']);
			
			if ~file
				% The user canceled. Do nothing.
				return
			end
			
			vt_regions = struct();
			vt_regions.regions = this.regions;
			vt_regions.videoName = this.videoName;
			
			save(fullfile(path, file), 'vt_regions');
		end
	end
end