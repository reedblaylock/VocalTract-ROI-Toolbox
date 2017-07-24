classdef (Abstract) ActionDispatcherWithoutData < vt.ActionDispatcher
	
	properties
	end
	
	methods
		function [] = dispatchAction(this, ~, ~)
			action = this.getAction();
			notify(this, action);
		end
	end
	
end

