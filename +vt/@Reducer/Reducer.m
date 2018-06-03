classdef Reducer < vt.Listener & vt.State.Setter
	% This is where all your reducers go.
	% Actions are dispatched by emitting events from various classes. Those
	% action-events are registered here in the Reducer. Each action-event
	% gets its own reducer.
	
	properties
		stateObj
	end
	
	methods
		% Constructor function. Receives a vt.State object.
		function this = Reducer(stateObj)
			this.stateObj = stateObj;
			
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
			newState = struct();
			oldState = this.stateObj.state;
			
			% Frame functions
			newState.currentFrameNo = this.currentFrameNo(oldState.currentFrameNo, actionData);
			newState.frameType = this.frameType(oldState.frameType, actionData);
			
			% Video functions
			newState.video = this.video(oldState.video, actionData);
			
			% Region functions
			newState.regions = this.regions(oldState.regions, actionData);
			newState.currentRegion = this.currentRegion(oldState.currentRegion, actionData);
			
			% isEditing functions
			newState.isEditing = this.isEditing(oldState.isEditing, actionData);
			
			this.stateObj.state = newState;
		end
		
		% Initialize the vt.State object by reducing without any input
		% parameters.
		function [] = initializeState(this)
			newState = struct();
			
			% Frame functions
			newState.currentFrameNo = this.currentFrameNo();
			newState.frameType = this.frameType();
			
			% Video functions
			newState.video = this.video();
			
			% Region functions
			newState.regions = this.regions();
			newState.currentRegion = this.currentRegion();
			
			% isEditing functions
			newState.isEditing = this.isEditing();
			
			this.stateObj.state = newState;
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

