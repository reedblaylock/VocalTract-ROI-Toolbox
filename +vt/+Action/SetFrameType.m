classdef SetFrameType < redux.Action
	events
		SET_FRAME_TYPE
	end
	
	properties
		frameType
	end
	
	methods
		function [] = prepare(this, frameType)
			this.frameType = frameType;
		end
	end
end

