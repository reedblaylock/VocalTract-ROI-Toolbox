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
		
		function [] = register(this, actionObj)
			p = inputParser;
			addRequired(p, 'action', @(action) isa(action, 'vt.Action'));
			parse(p, actionObj);
			
			actionName = p.Results.action.getName();
			try
				addlistener( ...
					p.Results.action, ...
					actionName, ...
					@(source, eventData) this.reduce(source, eventData)...
				);
			catch excp
				this.log.exception(excp);
				% TODO: stop executing
			end
		end
		
		% The main reduce function. Calls all the other reduce functions in this
		% class (by calling some from within others).
		function [] = reduce(this, ~, eventData)
			actionData = eventData.data;
			
			% Frame functions
			this.state.currentFrameNo = this.currentFrameNo(this.state.currentFrameNo, actionData);
			this.state.frameType = this.frameType(this.state.frameType, actionData);
			
			% Video functions
			this.state.video = this.video(this.state.video, actionData);
			
			% Region functions
			this.state.regions = this.regions(this.state.regions, actionData);
			this.state.currentRegion = this.currentRegion(this.state.currentRegion, actionData);
			
			% isEditing functions
			this.state.isEditing = this.isEditing(this.state.isEditing, actionData);
		end
		
		% Initialize the vt.State object by reducing without any input
		% parameters.
		function [] = initializeState(this)
			% Frame functions
			this.state.currentFrameNo = this.currentFrameNo();
			this.state.frameType = this.frameType();
			
			% Video functions
			this.state.video = this.video();
			
			% Region functions
			this.state.regions = this.regions();
			this.state.currentRegion = this.currentRegion();
			
			% isEditing functions
			this.state.isEditing = this.isEditing();
		end
		
		% Function declarations for the other reducer methods. You can find them
		% in +vt/@Reducer
		newState = currentFrameNo(this, oldState, actionData)
		newState = currentRegion(this, oldState, actionData)
% 		newState = frame(this, oldState, action)
		newState = frameType(this, oldState, actionData)
		newState = isEditing(this, oldState, actionData)
% 		newState = region(this, oldState, action)
		newState = regions(this, oldState, actionData)
		newState = video(this, oldState, actionData)
	end
	
end

