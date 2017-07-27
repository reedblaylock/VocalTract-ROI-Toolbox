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
			p = inputParser;
			p.addRequired('state', @(state) (isa(state, 'vt.State')));
			p.parse(state);
			
			this.state = p.Results.state;
		end
		
% 		function [] = registerEventListener(this, obj)
% 			p = inputParser;
% 			p.addRequired('this', @(this) isa(this, 'vt.Reducer'));
% 			p.addRequired('obj', @(obj) isa(obj, 'vt.ActionDispatcher'));
% 			p.parse(this, obj);
% 			
% 			action = p.Results.obj.getAction();
% 			method = this.action2method(action);
% 			
% 			addlistener( ...
% 				p.Results.obj, ...
% 				action, ...
% 				@(source, eventdata) method(this, source, eventdata)...
% 			);
% 		end
% 		
% 		function [] = registerActionListener(this, obj)
% 			this.registerEventListener(obj);
% 		end
	end
	
	% Method names are found using the camelCase function.
	% Examples :
	%   Event 'INCREMENT' --> Method 'increment'
	%   Event 'CLOSE_GUI' --> Method 'closeGui'
	%   Event 'LOAD_VOCAL_TRACT' --> Method 'loadVocalTract'
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
			% TODO: Should the reducer also change the current frame number, or
			% should that come from a separate event triggered when a component
			% gets a video update? (The latter, I think)
			if(isempty(this.state.video))
				this.state.video = eventData.data;
				this.state.currentFrameNo = 1;
			else
				this.state.video = eventData.data;
			end
		end
	end
	
end

