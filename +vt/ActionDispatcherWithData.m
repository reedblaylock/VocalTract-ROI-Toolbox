classdef (Abstract) ActionDispatcherWithData < vt.ActionDispatcher
	
	properties
		data
	end
	
	methods
		function [] = dispatchAction(this, ~, ~)
			action = this.getAction();
			actionData = vt.EventData(this.data);
			notify(this, action, actionData);
		end
		
		function [] = setData(this, data)
			this.data = data;
		end
	end
	
end

