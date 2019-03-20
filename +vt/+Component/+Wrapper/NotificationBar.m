% This class handles the more complicated logic required before updating the
% GUI's NotificationBar.
classdef NotificationBar < redux.Root & redux.Component.Wrapper
	properties
		% An object of class redux.Component.Text.NotificationBar
		notificationBar
		
		% redux.Root has a log property that will hold a redux.Log object (set in
		% redux.Gui).
	end
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Create a logical wrapper around the NotificationBar component.
		% Register an event listener for the log property (see redux.Root).
		function this = NotificationBar(notificationBar)
			this.notificationBar = notificationBar;
			
% 			addlistener( ...
% 				this, ...
% 				'log', ...
% 				'PostSet', ...
% 				@(source, event) addLogListener(this, source, event) ...
% 			);
		end
		
		%%%%% OTHER %%%%%
		
		% Add a listener to the log property's action.
		function [] = addLogListener(this, ~, ~)
			addlistener( ...
				this.log.action, ...
				'NOTIFY_ERROR', ...
				@(source, event) triggerUpdate(this, source, event) ...
			);
		end
		
		% When Log dispatches an action, this function updates the
		% NotificationBar component with the appropriate message and color.
		function [] = triggerUpdate(this, ~, eventData)
			error = eventData.data;
			if(ischar(error))
				this.notificationBar.update(error, 'yellow');
			else
% 				message = getReport(error, 'basic');
				message = error.message;
				this.notificationBar.update(message, 'red');
			end
		end
	end
end

