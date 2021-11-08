classdef DeleteAllRegions < redux.Component.MenuItem & redux.Action.Dispatcher
	properties
		
	end
	
	methods
		function this = DeleteAllRegions(parent, label)
			p = redux.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			parse(p, parent, label);
			
			this@redux.Component.MenuItem(p.Results.parent, p.Results.label);
			
			this.setCallback();
		end
		
		function [] = dispatchAction(this, ~, ~)
			action = this.actionFactory.actions.DELETE_ALL_REGIONS;
			action.prepare();
			action.dispatch();
		end
	end
	
end

