function newState = currentFrameNo(varargin)
	p = inputParser;
	addOptional(p, 'oldState', []);
	addOptional(p, 'action', struct('type', ''));
	p.StructExpand = false;
	parse(p, varargin{:});

	switch(p.Results.action.type)
		case 'SET_CURRENT_FRAME_NO'
			newState = p.Results.action.frameNo;
		case 'LOAD_VIDEO'
			newState = 1;
		otherwise
			newState = p.Results.oldState;
	end
end