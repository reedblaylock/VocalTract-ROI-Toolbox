function newState = currentRegion(this, oldState, action)
	p = inputparser;
	addOptional(p, 'oldState', []);
	addOptional(p, 'action', struct('type', ''));
	parse(p, oldState, action);

	switch(p.Results.action.type)
		case 'NEW_REGION'
			newState = p.Results.action.region.id;
		case 'SET_CURRENT_REGION'
			newState = p.Results.action.id;
 		case {'STOP_EDITING', 'DELETE_REGION'}
			newState = [];
		otherwise
			newState = p.Results.oldState;
	end
end