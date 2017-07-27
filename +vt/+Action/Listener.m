% The ActionListener is the first stop for all actions triggered by users,
% whether they come from shortcut keystrokes or interaction with the GUI. The
% ActionListener decides what to do with the action. It might:
% - pass the action directly to the Reducer
% - trigger additional program logic that then updates State via Reducer
% - update a component without passing through the Reducer at all
classdef Listener < vt.Listener
	properties
		reducer
	end
	
	methods
		function this = Listener()
			this.reducer = vt.Reducer();
		end
		
		function [] = registerAction(this, action)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Action.Listener'));
			p.addRequired('action', @(action) isa(action, 'vt.Action'));
			p.parse(this, action);
			
			actionName = p.Results.action.getName();
			
			% Does this Action have a corresponding method in ActionListener?
			if(this.isMethod(actionName))
				% Yes -- do that method
				this.register(action);
			else
				% No -- register the Action with the Reducer instead
				this.reducer.register(action);
			end
		end
		
		function [] = closeGui(~, ~, ~)
			closereq();
		end
		
		function [] = help(~, ~, ~)
			disp('Showing Help...');
		end
		
		function [] = load(this, ~, eventData)
			disp('Loading video data...');
			
			videoLoader = vt.Video.Loader();
			try
				assert(videoLoader.loadVideo(eventData.data));
				% Increment the frame here? Or, do it from the VideoLoader?
			catch excp
				this.log.exception(excp);
				% TODO: Do something about this
			end
		end
	end
	
end

