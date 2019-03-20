classdef Export < redux.Component.MenuItem & redux.State.Listener & redux.Action.Dispatcher
	properties
		regions
		video
	end
	
	methods
		function this = Export(parent, label)
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
		
		function [] = onRegionsChange(this, state)
			this.regions = state.regions;
		end
		
		function [] = dispatchAction(this, source, eventData)
			action = this.actionFactory.actions.EXPORT;
			action.prepare(this.regions, this.video);
			action.dispatch();
		end
	end
	
end

