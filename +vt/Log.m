classdef Log < handle
	properties (Constant = true)
		filename = 'error.log'
	end
	
	methods
		function [] = on(this)
			diary(this.filename);
		end
		
		function [] = off(~)
			diary off;
		end
		
		function [] = exception(this, exception)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Log'));
			p.addRequired('exception', @(exception) isa(exception, 'MException'));
			p.parse(this, exception);
			
			% Since the error is being caught, it probably won't get displayed
			% in the diary. Put it there explicitly?
			
			% Dispatch error event to be shown in GUI
			% But watch out for loops caused when that thread fails...
			this.triggerNotificationBarUpdate(exception);
		end
		
		function [] = triggerNotificationBarUpdate(this, exception)
			string = ''; % get user-friendly string from Exception
			this.dispatchAction(); % send the string and a corresponding color to the notification bar via an event
		end
	end
	
end

