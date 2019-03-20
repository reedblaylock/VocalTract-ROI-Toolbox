classdef Help < redux.Component.MenuItem & redux.Action.Dispatcher
	methods
		function this = Help(parent, label)
			this@redux.Component.MenuItem(parent, label);
			
			this.setCallback();
		end
		
		function [] = dispatchAction(this, source, eventData)
			action = this.actionFactory.actions.HELP;
			action.prepare();
			action.dispatch();
		end
	end
	
end

