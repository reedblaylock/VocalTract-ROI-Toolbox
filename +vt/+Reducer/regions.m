function newState = regions(varargin)
	p = inputParser;
	addOptional(p, 'oldState', {});
	addOptional(p, 'action', struct('type', ''));
	p.StructExpand = false;
	parse(p, varargin{:});

	switch(p.Results.action.type)
		case 'NEW_REGION'
			newState = horzcat(p.Results.oldState, p.Results.action.region);
		case 'CHANGE_REGION_PARAMETER'
			% Find region by ID
			for iRegion = 1:numel(p.Results.oldState)
				if p.Results.oldState{iRegion}.id == p.Results.action.region.id
					break;
				end
			end
			
			% Replace old region with new region
			newState = p.Results.oldState;
			newState{iRegion} = p.Results.action.region;
		case 'DELETE_REGION'
			% Find region by ID
			for iRegion = 1:numel(p.Results.oldState)
				if p.Results.oldState{iRegion}.id == p.Results.action.id
					break;
				end
			end
			
			newState = p.Results.oldState;
			newState(iRegion) = [];
		case 'IMPORT_REGIONS'
			newState = p.Results.oldState;
			for iRegion = 1:numel(p.Results.action.regions)
				newState = horzcat(newState, p.Results.action.regions{iRegion});
			end
		otherwise
			newState = p.Results.oldState;
	end
end