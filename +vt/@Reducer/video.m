function newState = video(this, oldState, action)
	p = inputparser;
	addOptional(p, 'oldState', []);
	addOptional(p, 'action', struct('type', ''));
	parse(p, oldState, action);

	switch(p.Results.action.type)
		case 'LOAD_VIDEO'
			newState = p.Results.action.video;
		otherwise
			newState = p.Results.oldState;
	end
end