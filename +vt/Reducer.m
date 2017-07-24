classdef Reducer < handle
	% This is where all your reducers go.
	% Actions are dispatched by emitting events from various classes. Those
	% action-events are registered here in the Reducer. Each action-event
	% gets its own reducer.
	%
	% Right now, it seems like every reducer has to know the overall
	% structure of the state; it would be nice if a reducer only had to
	% get/set a small portion of state.
	
	properties
		state
	end
	
	methods
		function this = Reducer(state)
			p = inputParser;
			p.addRequired('state', @(state) (isa(state, 'vt.State')));
			p.parse(state);
			
			this.state = p.Results.state;
		end
		
		function [] = registerEventListener(this, obj)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Reducer'));
			p.addRequired('obj', @(obj) isa(obj, 'vt.ActionDispatcher'));
			p.parse(this, obj);
			
			action = p.Results.obj.getAction();
			method = str2func(this.camelCase(action));
			
			addlistener( ...
				p.Results.obj, ...
				action, ...
				@(source, eventdata) method(this, source, eventdata)...
			);
		end
		
		function [] = registerActionListener(this, obj)
			this.registerEventListener(obj);
		end
		
		function methodName = camelCase(~, underscore_action)
			methodName = regexprep(lower(underscore_action), '_+(\w?)', '${upper($1)}');
		end
	end
	
	% Method names are found using the camelCase function.
	% Examples :
	%   Event 'INCREMENT' --> Method 'increment'
	%   Event 'CLOSE_GUI' --> Method 'closeGui'
	%   Event 'LOAD_VOCAL_TRACT' --> Method 'loadVocalTract'
	methods (Access = private)
		function [] = increment(this, ~, eventData)
			this.state.currentFrame = this.state.currentFrame + eventData.data;
		end
		
		function [] = closeGui(~, ~, ~)
			closereq();
		end
		
		function [] = loadAvi(this, source, eventdata)
			disp('Loading AVI...');
			this.state.isLoading = 'avi';
		end
		
		function [] = setVideoData(this, source, eventData)
			disp('Loading video data...');
			
			fields = fieldnames(eventData.data);
			for f = 1:numel(fields)
				this.state.(fields{f}) = eventData.data{f};
			end
			
			this.finishedLoading(source, eventdata);
		end
		
		function [] = finishedLoading(this, source, eventdata)
			disp('Done loading!');
			this.state.isLoading = false;
		end
		
		function [] = loadVocalTract(this, source, eventdata)
			disp('Loading VocalTract...');
		end
		
		function [] = help(this, source, eventdata)
			disp('Showing Help...');
		end
	end
	
end

