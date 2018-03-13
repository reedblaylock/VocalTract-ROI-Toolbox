function newState = frame(this, oldState, action)
	p = inputparser;
	addOptional(p, 'oldState', struct('currentFrameNo', [], 'frameType', []));
	addOptional(p, 'action', struct('type', ''));
	parse(p, oldState, action);

	newState = struct( ...
		'currentFrameNo', currentFrameNo(this, p.Results.oldState.currentFrameNo, p.Results.action), ...
		'frameType', frameType(this, p.Results.oldState.frameType, p.Results.action) ...
	);
end