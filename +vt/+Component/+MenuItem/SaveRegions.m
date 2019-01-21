classdef SaveRegions < vt.Component.MenuItem & vt.State.Listener & vt.Action.Dispatcher
	properties
		regions
		video
	end
	
	methods
		function this = SaveRegions(parent, label)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			parse(p, parent, label);
			
			this@vt.Component.MenuItem(p.Results.parent, p.Results.label);
			
			this.setCallback();
		end
		
		function [] = onRegionsChange(this, state)
			this.regions = state.regions;
		end
		
		function [] = onVideoChange(this, state)
			this.video = state.video;
		end
		
		function [] = dispatchAction(this, ~, ~)
			action = this.actionFactory.actions.SAVE_REGIONS;
			action.prepare(this.regions, this.video);
			action.dispatch();
		end
	end
	
end

