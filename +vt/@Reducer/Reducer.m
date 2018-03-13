classdef Reducer < vt.Listener & vt.State.Setter
	% This is where all your reducers go.
	% Actions are dispatched by emitting events from various classes. Those
	% action-events are registered here in the Reducer. Each action-event
	% gets its own reducer.
	
	properties
		state
	end
	
	methods
		% Constructor function. Receives a vt.State object.
		function this = Reducer(state)
			this.state = state;
			
			this.initializeState();
		end
		
		% The main reduce function. Calls all the other reduce functions in this
		% class (by calling some from within others).
		function [] = reduce(this, action)
			this.state.frame = this.frame(this.state.frame, action);
			this.state.video = this.video(this.state.video, action);
			this.state.region = this.region(this.state.region, action);
			this.state.isEditing = this.isEditing(this.state.isEditing, action);
		end
		
		% Initialize the vt.State object by reducing without any input
		% parameters.
		function [] = initializeState(this)
			this.state.frame = this.frame();
			this.state.video = this.video();
			this.state.region = this.region();
			this.state.isEditing = this.isEditing();
		end
		
		% Function declarations for the other reducer methods. You can find them
		% in +vt/@Reducer
		newState = currentFrameNo(this, oldState, action)
		newState = currentRegion(this, oldState, action)
		newState = frame(this, oldState, action)
		newState = frameType(this, oldState, action)
		newState = isEditing(oldState, action)
		newState = region(this, oldState, action)
		newState = regions(this, oldState, action)
		newState = video(this, oldState, action)
	end
	
end

