classdef (Sealed) State < handle
	% SetObservable emits PreSet and PostSet events.
	%
	% AbortSet will prevent the PostSet event from being emitted based on
	% isequal(). Non-static objects will not be considered equal, even if their
	% property values are identical.
	properties (SetObservable = true, AbortSet = true)
		isLoading
		
		% Video data
		width
		height
		nFrames
		frameRate
		matrix
		currentFrame
	end
	
	methods
		function [] = initialize(this)
			this.isLoading = false;
			
			%
			this.width = 0;
			this.height = 0;
			this.nFrames = 0;
			this.frameRate = 0;
			this.matrix = [];
			this.currentFrame = 0;
		end
	end
	
end

