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
			if(isa(videoLoader, 'vt.Root'))
				videoLoader.log = this.log;
			end
			this.reducer.register(videoLoader.action);
			try
				tf = videoLoader.loadVideo(eventData.data);
				if(~tf), return, end
			catch excp
				this.log.exception(excp);
				return
				% TODO: Do something about this
			end
			
% 			% set frameType to 'frame'
% 			action = vt.Action.SetFrameType;
% 			this.reducer.register(action);
% 			action.dispatch('frame');
			
			% Set currentFrameNo to 1
			action = vt.Action.SetCurrentFrameNo;
			this.reducer.register(action);
			action.dispatch(1);
		end
	end
	
end

