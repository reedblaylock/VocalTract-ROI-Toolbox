function newState = region(this, varargin)
	p = inputParser;
	addOptional(p, 'oldState', struct('regions', {}, 'currentRegion', []));
	addOptional(p, 'action', struct('type', ''));
	p.StructExpand = false;
	parse(p, varargin{:});

	newState = struct( ...
		'regions', regions(this, p.Results.oldState.regions, p.Results.action), ...
		'currentRegion', currentRegion(this, p.Results.oldState.currentRegion, p.Results.action) ...
	);
end

