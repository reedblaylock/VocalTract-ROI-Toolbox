classdef NotificationBar < vt.Root & vt.Component.Wrapper
	properties
		notificationBar
	end
	
	methods
		function this = NotificationBar(notificationBar)
			this.notificationBar = notificationBar;
			
			addlistener( ...
				this.log, ...
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
			catch err
				disp('The error was in the wrapper!');
			end
		end
	end
end

