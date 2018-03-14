classdef SetCurrentFrameNo < vt.Action
	events
		SET_CURRENT_FRAME_NO
	end
	
	properties
		frameNo
	end
	
	methods
		function [] = prepare(this, frameNo, maxFrame)
			if(frameNo > maxFrame), frameNo = maxFrame; end
			if(frameNo < 1), frameNo = 1; end
			
			this.frameNo = frameNo;
		end
	end
end

