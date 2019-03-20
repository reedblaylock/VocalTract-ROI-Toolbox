function newState = frameType(varargin)
	p = inputParser;
	addOptional(p, 'oldState', 'frame', @(oldState) ischar(oldState));
	addOptional(p, 'action', struct('type', ''));
	p.StructExpand = false;
	parse(p, varargin{:});

	switch(p.Results.action.type)
		case 'SET_FRAME_TYPE'
			newState = p.Results.action.frameType;
		otherwise
			newState = p.Results.oldState;
	end
end