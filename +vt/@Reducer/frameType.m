function newState = frameType(this, oldState, action)
	p = inputparser;
	addOptional(p, 'oldState', []);
	addOptional(p, 'action', struct('type', ''));
	parse(p, oldState, action);

	switch(p.Results.action.type)
		case 'SET_FRAME_TYPE'
			newState = p.Results.action.frameType;
		otherwise
			newState = p.Results.oldState;
	end
end