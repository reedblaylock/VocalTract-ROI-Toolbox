function newState = currentFrameNo(this, oldState, action)
	p = inputparser;
	addOptional(p, 'oldState', []);
	addOptional(p, 'action', struct('type', ''));
	parse(p, oldState, action);

	switch(p.Results.action.type)
		case 'SET_CURRENT_FRAME_NO'
			newState = p.Results.action.frameNo;
		case 'LOAD_VIDEO'
			newState = 1;
		otherwise
			newState = p.Results.oldState;
	end
end