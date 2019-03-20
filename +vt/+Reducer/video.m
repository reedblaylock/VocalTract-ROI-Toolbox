function newState = video(varargin)
	p = inputParser;
	addOptional(p, 'oldState', []);
	addOptional(p, 'action', struct('type', ''));
	p.StructExpand = false;
	parse(p, varargin{:});

	switch(p.Results.action.type)
		case 'LOAD_VIDEO'
			newState = p.Results.action.video;
		otherwise
			newState = p.Results.oldState;
	end
end