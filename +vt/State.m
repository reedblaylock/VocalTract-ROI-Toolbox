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
			this.video = [];
			this.currentFrame = 0;
		end
	end
	
end

