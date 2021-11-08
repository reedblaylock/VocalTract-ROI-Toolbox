function newState = isEditing(varargin)
	p = inputParser;
	addOptional(p, 'oldState', '', @(oldState) ischar(oldState) || isempty(oldState));
	addOptional(p, 'action', struct('type', ''));
	p.StructExpand = false;
	parse(p, varargin{:});
	
	switch(p.Results.action.type)
		case {'NEW_REGION', 'EDIT_REGION'}
			newState = 'region';
		case {'STOP_EDITING', 'DELETE_REGION', 'DELETE_ALL_REGIONS', 'SAVE_REGION'}
			newState = '';
		otherwise
			newState = p.Results.oldState;
	end
end