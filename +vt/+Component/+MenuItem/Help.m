classdef Help < vt.Component.MenuItem & vt.Action.Dispatcher
	methods
		function this = Help(parent, label)
			this@vt.Component.MenuItem(parent, label);
			
			this.setCallback();
		end
		
		function [] = dispatchAction(this, source, eventData)
			action = this.actionFactory.actions.HELP;
			action.prepare();
			action.dispatch();
		end
	end
	
end

