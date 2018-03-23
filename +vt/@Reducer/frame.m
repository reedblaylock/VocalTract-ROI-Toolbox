function newState = frame(this, varargin)
	p = inputParser;
	addOptional(p, 'oldState', struct('currentFrameNo', [], 'frameType', []));
	addOptional(p, 'action', struct('type', ''));
	p.StructExpand = false;
	parse(p, varargin{:});

	newState = struct( ...
		'currentFrameNo', currentFrameNo(this, p.Results.oldState.currentFrameNo, p.Results.action), ...
		'frameType', frameType(this, p.Results.oldState.frameType, p.Results.action) ...
	);
end