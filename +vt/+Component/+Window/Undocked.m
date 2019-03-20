classdef Undocked < redux.Component.Window & redux.Action.Dispatcher
	% NOTE: This class is an Action.Dispatcher, but it doesn't get initialized
	% with the rest of the components. When this class gets instantiated, it
	% needs to be done with an actionFactory component.
	
	methods
		function this = Undocked(name, actionFactory)
			this@redux.Component.Window(name);
			
			this.actionFactory = actionFactory;
			
			this.setCallback('CloseRequestFcn');
		end
		
		function [] = dispatchAction(this, ~, ~)
			action = this.actionFactory.actions.TOGGLE_DOCK;
			action.prepare();
			action.dispatch();
		end
	end
	
end

