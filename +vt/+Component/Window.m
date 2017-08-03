classdef Window < vt.Component & vt.State.Listener
	% This class has a default callback. Closing figures is often more trouble
	% than it's worth, so avoid doing a custom job. If you want to see an
	% example of a custom window callback, see the Exit button and
	% vt.Reducer.closeGui().
	
	properties
		baseName
	end
	
	methods
		function this = Window(name)
			p = vt.InputParser();
			p.addRequired('name', @ischar);
			p.parse(name);
			
			this.baseName = p.Results.name;
			
			this.handle = figure( ...
				'Name', this.baseName, ...
				'NumberTitle', 'off', ...
				'MenuBar', 'none', ...
				'Toolbar', 'none' ...
			);
		end
		
		function [] = onVideoChange(this, state)
			this.setParameters('Name', [this.baseName ' - ' state.video.fullpath]);
		end
		
		function [] = delete(this)
			delete@vt.State.Listener(this);
			this.log.off();
% 			delete(this.log)
% 			clear vt.Log;
		end
	end
	
end

