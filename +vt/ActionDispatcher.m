classdef (Abstract, AllowedSubclasses = {?vt.ActionDispatcherWithData, ?vt.ActionDispatcherWithoutData}) ActionDispatcher < handle
	
	properties
	end
	
	methods
		function action = getAction(this)
			e = events(this);
			action = e{1};
			if(strcmp(action, 'ObjectBeingDestroyed'))
				% Error: this class does not have an action specified
			end
		end
	end
	
	methods (Access = ?vt.Component)
		function [] = setCallback(this, callbackName)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.ActionDispatcher'));
			p.addOptional('callbackName', 'Callback', @ischar);
			p.parse(this, callbackName);
			
			set( ...
				this.handle, ...
				p.Results.callbackName, ...
				@(source, eventdata) dispatchAction(this, source, eventdata) ...
			);
		end
		
		[] = dispatchAction(this, ~, ~);
	end
	
end

