classdef App < vt.Component.Window & vt.State.Listener
	methods
		function this = App(name)
			p = vt.InputParser();
			p.addRequired('name', @ischar);
			p.parse(name);
			
			this@vt.Component.Window(name);
		end
		
		function [] = onVideoChange(this, state)
			this.setParameters('Name', [this.baseName ' - ' state.video.fullpath]);
		end
		
		function [] = delete(this)
			delete@vt.State.Listener(this);
			this.log.off();
% 			clear vt.Config;
% 			clear vt.Action.NewRegion;
% 			delete(this.log)
% 			clear vt.Log;
		end
	end
	
end

