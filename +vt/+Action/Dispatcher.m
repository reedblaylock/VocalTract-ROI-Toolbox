% vt.Action.Dispatcher is an abstract class that has a vt.Action.Factory
% property. Any subclass of vt.Action.Dispatcher can access the
% vt.Action.Factory to get access to pre-registered vt.Actions.
classdef (Abstract) Dispatcher < vt.Root
	properties
		actionFactory
	end
	
	methods
		function [] = dispatchAction()
			this.action.dispatch();
		end
	end
end

