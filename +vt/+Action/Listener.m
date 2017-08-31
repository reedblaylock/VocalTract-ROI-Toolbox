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
			p = vt.InputParser;
			p.addRequired('reducer', @(reducer) isa(reducer, 'vt.Reducer'));
			parse(p, reducer);
			
			this.reducer = p.Results.reducer;
		end
		
		function [] = registerAction(this, action)
			p = vt.InputParser;
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
		
		function [] = notifyFrameClick(this, ~, eventData)
			isEditing = eventData.data.isEditing;
			disp('click!');
			switch(isEditing)
				case 'region'
					% We're in region-editing mode, and the frame was clicked.
					% Put down an origin point.
					action = vt.Action.ChangeCurrentRegionOrigin();
					coordinates = eventData.data.coordinates;
					this.reducer.register(action);
					action.dispatch(coordinates);
				case 'midlineNew'
					
				case 'midlineEdit'
					
				otherwise
					% We're not in editing mode, and the frame was clicked.
					% 1. The click location is within a region on the frame, so
					%    set currentRegion = the clicked region
					% 2. The click location is not within a region, so clear the
					%    currentRegion (or, do nothing)
					% TODO: Take the logic out of the reducer somehow
					action = vt.Action.SetCurrentRegion();
					coordinates = eventData.data.coordinates;
					this.reducer.register(action);
					action.dispatch(coordinates);
			end
		end
		
		function [] = newMidline(this, ~, ~)
			% Automatically switch to standard-deviation mode
			action = vt.Action.SetFrameType();
			this.reducer.register(action);
			this.action.dispatch('std dev');
			
			action = vt.Action.NewMidline();
			this.reducer.register(action);
			this.action.dispatch();
		end
		
		function [] = createMidline(this, ~, eventData)
			% Create the object
			dynamicProgrammer = vt.DynamicProgrammer();
			if(isa(dynamicProgrammer, 'vt.Root'))
				dynamicProgrammer.log = this.log;
			end
			
			dynamicProgrammer.setImage = eventData.data.image;
			
			% When this object is done doing its thing, it should emit an action
			this.reducer.register(dynamicProgrammer.action);
			
			try
				% eventData.data.points = [p1x p1y; p2x p2y; p3x p3y];
				tf = dynamicProgrammer.findPath(eventData.data.points);
				if(~tf), return, end
			catch excp
				this.log.exception(excp);
			end
			
			% Follow up action
			action = vt.Action.SetIsEditing();
			this.reducer.register(action);
			action.dispatch('midlineEdit');
		end
	end
	
end

