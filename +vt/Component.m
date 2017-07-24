classdef (Abstract) Component < handle
	
	properties
		handle
		callbackName = 'Callback'
	end
	
	methods
		function [] = registerStateListener(this, state, propertyName)
			addlistener(state, propertyName, 'PostSet', @(source, eventdata) redraw(this, source, eventdata.AffectedObject.(propertyName)));
		end
		
		[] = setCallbackName(this);
		
		redraw(this, source, eventdata);
		
		% this, source, eventdata, action
		% - You'll probably want to send eventdata by default so that the
		% event.EventData class can be subclassed for specific data purposes
		% - You should also consider sending 'source', not 'this', as the first
		% variable. Both will work because they're both handles, but the class
		% isn't really the source of the event.
		function [] = dispatchAction(this, ~, ~, action)
			notify(this, action);
		end
		
		function [] = setCallback(this, action)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Component'));
			p.addRequired('action', @ischar);
			p.parse(this, action);
			
			set( ...
				this.handle, ...
				this.callbackName, ...
				@(source, eventdata) dispatchAction(this, source, eventdata, p.Results.action) ...
			);
		end
		
		function [] = setParameters(this, varargin)
			p = inputParser;
			p.KeepUnmatched = true;
			p.addRequired('this', @(this) isa(this, 'vt.Component'));
			parse(p, this, varargin{:});
			
			params = fieldnames(p.Unmatched);

			for i = 1:numel(params)
				set(this.handle, params{i}, p.Unmatched.(params{i}));
			end
		end
	end
	
end

