classdef Reducer < vt.Listener & vt.State.Setter
	% This is where all your reducers go.
	% Actions are dispatched by emitting events from various classes. Those
	% action-events are registered here in the Reducer. Each action-event
	% gets its own reducer.
	
	properties
		stateObj
		reducerPath = 'D:\Programs\MATLAB\R2014b\toolbox\VocalTract ROI Toolbox\+vt\@Reducer';
	end
	
	methods
		% Constructor function. Receives a vt.State object.
		function this = Reducer(stateObj)
			this.stateObj = stateObj;
			
			this.reduce();
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
		function [] = reduce(this, ~, varargin)
			p = inputParser;
			addOptional(p, 'eventData', struct(), @(eventData) isa(eventData, 'vt.EventData'));
			p.StructExpand = false;
			parse(p, varargin{:});
			
			oldState = this.stateObj.state;
			newState = struct();
			
			reducerFcns = this.getReducerFcns();
			
			for fcnidx = 1:numel(reducerFcns)
				method = reducerFcns{fcnidx};
				try
					assert(this.isMethod(method));
					if numel(fieldnames(p.Results.eventData))
						actionData = p.Results.eventData.data;
						newState.(method) = this.(method)(oldState.(method), actionData);
					else
						newState.(method) = this.(method)();
					end
					
				catch excp
					this.log.exception(excp);
					% TODO: stop executing
				end
			end
			
			this.stateObj.state = newState;
		end
		
		function reducerFcns = getReducerFcns(this)
			reducerCls = what(this.reducerPath);
			reducerFcns = reducerCls(1).m;
			reducerFcns(ismember(reducerFcns, 'Reducer.m')) = [];
			reducerFcns = cellfun(@(x) x(1:end-2), reducerFcns, 'un', 0);
		end
		
		% Function declarations for the other reducer methods. You can find them
		% in +vt/@Reducer
% 		newState = currentFrameNo(this, oldState, actionData)
% 		newState = currentRegion(this, oldState, actionData)
% 		newState = frameType(this, oldState, actionData)
% 		newState = isEditing(this, oldState, actionData)
% 		newState = regions(this, oldState, actionData)
% 		newState = video(this, oldState, actionData)
% 		newState = videoIsDocked(this, oldState, actionData)
	end
	
end

