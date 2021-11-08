function newState = currentRegion(varargin)
	p = inputParser;
	addOptional(p, 'oldState', []);
	addOptional(p, 'action', struct('type', ''));
	p.StructExpand = false;
	parse(p, varargin{:});

	switch(p.Results.action.type)
		case 'NEW_REGION'
			newState = p.Results.action.region.id;
		case 'SET_CURRENT_REGION'
			newState = p.Results.action.id;
%  		case {'STOP_EDITING', 'DELETE_REGION'}
		case {'DELETE_REGION', 'DELETE_ALL_REGIONS'}
			newState = [];
		otherwise
			newState = p.Results.oldState;
	end
end