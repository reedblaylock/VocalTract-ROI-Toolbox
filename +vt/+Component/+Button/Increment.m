classdef Increment < vt.Button & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.Increment
	end
	
	methods
		function this = Increment(parent, label, incrementValue)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			p.addRequired('incrementValue', @isnumeric);
			p.parse(parent, label, incrementValue);
			
			this@vt.Button(parent, label);
			this@vt.Action.Dispatcher(data);
		
			this.setCallback();
		end
	end
	
end

