% This class makes the menu items for loading files. You can pass any string
% you want as the data parameter, and a call will be made to redux.Reducer.load
% with the data you want representing the file signature (defined by you).
% For instance, passing 'avi' as the data parameter tells redux.Reducer to use
% the function that loads AVIs as opposed to VocalTract objects or something
% else.
%
% If you want to make your own loader, start by putting another one of these
% redux.LoadMenuItems in the menu bar, then put your implementation logic in
% redux.Reducer (and any classes it might need to work with).
	
classdef CorrectHeadMovement < redux.Component.MenuItem & redux.State.Listener & redux.Action.Dispatcher
	properties
		video
	end
	
	methods
		function this = CorrectHeadMovement(parent, label)
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
			action = this.actionFactory.actions.CORRECT_HEAD_MOVEMENT;
			action.prepare(this.video);
			action.dispatch();
		end
	end
	
end

