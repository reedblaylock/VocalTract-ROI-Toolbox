function newState = isEditing(this, oldState, action)
	p = inputparser;
	addOptional(p, 'oldState', '');
	addOptional(p, 'action', struct('type', ''));
	parse(p, oldState, action);
	
	switch(p.Results.action.type)
		case {'NEW_REGION', 'EDIT_REGION'}
			newState = 'region';
		case {'STOP_EDITING', 'DELETE_REGION', 'SAVE_REGION'}
			newState = '';
		otherwise
			newState = p.Results.oldState;
	end
end