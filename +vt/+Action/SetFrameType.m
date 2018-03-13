classdef SetFrameType < vt.Action
	events
		SET_FRAME_TYPE
	end
	
	properties
		frameType
	end
	
	methods
		function this = SetFrameType(frameType)
			this.frameType = frameType;
		end
	end
end

