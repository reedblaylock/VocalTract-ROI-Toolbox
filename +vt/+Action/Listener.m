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
		function this = Listener(reducer)
			p = inputParser;
			p.addRequired('reducer', @(reducer) isa(reducer, 'vt.Reducer'));
			parse(p, reducer);
			
			this.reducer = p.Results.reducer;
		end
		
		function [] = registerAction(this, action)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Action.Listener'));
			p.addRequired('action', @(action) isa(action, 'vt.Action'));
			p.parse(this, action);
			
			actionName = p.Results.action.getName();
			methodName = this.action2method(actionName);
			
			% Does this Action have a corresponding method in ActionListener?
			if(this.isMethod(methodName))
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
			this.reducer.register(videoLoader.action);
			try
				assert(videoLoader.loadVideo(eventData.data));
				% Increment the frame here? Or, do it from the VideoLoader?
				action = vt.Action.SetCurrentFrameNo;
				this.reducer.register(action);
				action.dispatch(1);
			catch excp
				this.log.exception(excp);
				% TODO: Do something about this
			end
		end
	end
	
end

