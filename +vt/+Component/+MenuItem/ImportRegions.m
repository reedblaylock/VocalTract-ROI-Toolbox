classdef ImportRegions < redux.Component.MenuItem & redux.State.Listener & redux.Action.Dispatcher
	properties
		regions
		video
	end
	
	methods
		function this = ImportRegions(parent, label)
			p = redux.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			parse(p, parent, label);
			
			this@redux.Component.MenuItem(p.Results.parent, p.Results.label);
			
			this.setCallback();
		end
		
		function [] = onVideoChange(this, state)
			this.video = state.video;
		end
		
		function [] = dispatchAction(this, ~, ~)
			action = this.actionFactory.actions.IMPORT_REGIONS;
			action.prepare(this.video);
			action.dispatch();
		end
	end
	
end

