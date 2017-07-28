classdef NotificationBar < vt.Root & vt.Component.Wrapper
	properties
		notificationBar
	end
	
	methods
		function this = NotificationBar(notificationBar)
			this.notificationBar = notificationBar;
% 			action = vt.Action.NotifyError();
			
			addlistener( ...
				this, ...
				'log', ...
				'PostSet', ...
				@(source, event) addLogListener(this, source, event) ...
			);
		end
		
		function [] = addLogListener(this, ~, ~)
			addlistener( ...
				this.log.action, ...
				'NOTIFY_ERROR', ...
				@(source, event) triggerUpdate(this, source, event) ...
			);
		end
		
		function [] = triggerUpdate(this, ~, eventData)
			try
				error = eventData.data;
				if(ischar(error))
					this.notificationBar.update(error, 'yellow');
				else
					message = getReport(error, 'basic');
					this.notificationBar.update(message, 'red');
				end
			catch
				disp('The error was in the wrapper!');
			end
		end
	end
end

