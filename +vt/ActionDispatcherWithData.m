classdef (Abstract) ActionDispatcherWithData < vt.ActionDispatcher
	
	properties
		data
	end
	
	methods
		function [] = dispatchAction(this, ~, ~)
			action = this.getAction();
			notify(this, action, this.data);
		end
		
		function [] = setData(this, data)
			this.data = data;
		end
	end
	
end

