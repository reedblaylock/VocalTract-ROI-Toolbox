classdef ExportFrame < vt.Component.MenuItem & vt.State.Listener & vt.Action.Dispatcher
	properties
		currentFrameNo
		video
	end
	
	methods
		function this = ExportFrame(parent, label)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			parse(p, parent, label);
			
			this@vt.Component.MenuItem(p.Results.parent, p.Results.label);
			
			this.setCallback();
		end
		
		function [] = onVideoChange(this, state)
			this.video = state.video;
		end
		
		function [] = onCurrentFrameNoChange(this, state)
			this.currentFrameNo = state.currentFrameNo;
		end
		
		function [] = dispatchAction(this, source, eventData)
			action = this.actionFactory.actions.EXPORT_FRAME;
			action.prepare(this.video, this.currentFrameNo);
			action.dispatch();
		end
	end
	
end

