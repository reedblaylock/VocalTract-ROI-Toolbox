classdef Log < handle
	properties
		filename = 'error.log'
		debugMode
	end
	
	events
		NOTIFY_ERROR
	end
	
	methods
		function this = Log(varargin)
			p = inputParser;
			p.addOptional('debugMode', false, @islogical);
			parse(p, varargin{:});
			
			this.debugMode = p.Results.debugMode;
		end
		
		function [] = on(this)
			diary(this.filename);
		end
		
		function [] = off(~)
			diary off;
		end
		
		function [] = notifyError(this, exception)
			eventdata = vt.EventData(exception);
			notify(this, 'NOTIFY_ERROR', eventdata);
		end
		
		function [] = exception(this, exception)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Log'));
			p.addRequired('exception', @(exception) isa(exception, 'MException'));
			p.parse(this, exception);
			
			this.notifyError(exception);
			
			if(this.debugMode)
				rethrow(exception);
			end
		end
		
		function [] = warning(this, warning)
			this.notifyError(warning);
			
			if(this.debugMode)
% 				rethrow(warning);
			end
		end
	end
	
end

