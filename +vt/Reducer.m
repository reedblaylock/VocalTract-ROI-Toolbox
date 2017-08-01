classdef Reducer < vt.Listener & vt.State.Setter
	% This is where all your reducers go.
	% Actions are dispatched by emitting events from various classes. Those
	% action-events are registered here in the Reducer. Each action-event
	% gets its own reducer.
	%
	% Right now, it seems like every reducer has to know the overall
	% structure of the state; it would be nice if a reducer only had to
	% get/set a small portion of state.
	
	properties
		state
	end
	
	methods
		function this = Reducer(state)
			this.state = state;
		end
	end
	
	methods
		function [] = increment(this, ~, eventData)
			if(isempty(this.state.currentFrameNo))
				return
			end
			
			newFrameNo = this.state.currentFrameNo + eventData.data;
			if(newFrameNo > this.state.video.nFrames), newFrameNo = this.state.video.nFrames; end
			if(newFrameNo < 1), newFrameNo = 1; end
			this.state.currentFrameNo = newFrameNo;
		end
		
		function [] = setCurrentFrameNo(this, ~, eventData)
			newFrameNo = eventData.data;
			if(newFrameNo > this.state.video.nFrames), newFrameNo = this.state.video.nFrames; end
			if(newFrameNo < 1), newFrameNo = 1; end
			this.state.currentFrameNo = newFrameNo;
		end
		
		function [] = setVideo(this, ~, eventData)
			disp('Reducer: setVideo()');
			this.state.video = eventData.data;
		end
		
		function [] = setFrameType(this, ~, eventData)
			this.state.frameType = eventData.data;
		end
		
		function [] = newRegion(this, ~, ~)
			this.state.isEditing = 'region';
		end
		
		function [] = delete(~)
			disp('Reducer is being destroyed');
		end
	end
	
end

