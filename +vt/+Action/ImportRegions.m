classdef ImportRegions < redux.Action
	events
		IMPORT_REGIONS
	end
	
	properties
		regions
	end
	
	methods
		function [] = prepare(this, video)
			[file, path] = uigetfile('_regions.mat', 'Select regions file to open');
			
			if ~file
				% The user canceled. Do nothing.
				return
			end
			
			vtload = load(fullfile(path, file));
			regions = vtload.vt_regions.regions;
			
			% TODO: Check for regions that have somehow been corrupted, and fill
			% in the blank parameters with some default values
			
			for iRegion = 1:numel(regions)
				regions{iRegion}.timeseries = vt.Action.findTimeseries(regions{iRegion}, video);
			end
			
			this.regions = regions;
		end
	end
end