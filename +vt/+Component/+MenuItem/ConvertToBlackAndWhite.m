classdef ConvertToBlackAndWhite < redux.Component.MenuItem & redux.State.Listener & redux.Action.Dispatcher
	properties
		video
	end
	
	methods
		function this = ConvertToBlackAndWhite(parent, label)
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
		
		function [] = dispatchAction(this, source, eventData)
			action = this.actionFactory.actions.CONVERT_TO_BLACK_AND_WHITE;
			action.prepare(this.video);
			action.dispatch();
		end
	end
	
end

