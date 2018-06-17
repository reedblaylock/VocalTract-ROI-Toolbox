function newState = toggleVideoDock(this, varargin)
	p = inputParser;
	addOptional(p, 'oldState', true);
	addOptional(p, 'action', struct('type', ''));
	p.StructExpand = false;
	parse(p, varargin{:});

	switch(p.Results.action.type)
		case 'TOGGLE_DOCK'
			newState = ~p.Results.oldState;
		otherwise
			newState = p.Results.oldState;
	end
end