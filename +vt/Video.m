classdef Video < handle
	properties (SetAccess = immutable)
		filename
		fullpath
		width
		height
		nFrames
		frameRate
		matrix
	end
	
	methods
		function this = Video( filename, fullpath, width, height, nFrames, frameRate, matrix )
			p = inputParser;
			p.addRequired('filename', @ischar);
			p.addRequired('fullpath', @ischar);
			p.addRequired('width', @isnumeric);
			p.addRequired('height', @isnumeric);
			p.addRequired('nFrames', @isnumeric);
			p.addRequired('frameRate', @isnumeric);
			p.addRequired('matrix', @isnumeric);
			p.parse( filename, fullpath, width, height, nFrames, frameRate, matrix );
			
			this.filename  = p.Results.filename;
			this.fullpath  = p.Results.fullpath;
			this.width     = p.Results.width;
			this.height    = p.Results.height;
			this.nFrames   = p.Results.nFrames;
			this.frameRate = p.Results.frameRate;
			this.matrix    = p.Results.matrix;
		end
			
	end
end
