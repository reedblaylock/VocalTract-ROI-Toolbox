function newState = region(this, oldState, action)
	p = inputparser;
	addOptional(p, 'oldState', struct('regions', {}, 'currentRegion', []));
	addOptional(p, 'action', struct('type', ''));
	parse(p, oldState, action);

	newState = struct( ...
		'regions', regions(this, p.Results.oldState.regions, p.Results.action), ...
		'currentRegion', currentRegion(this, p.Results.oldState.currentRegion, p.Results.action) ...
	);
end

