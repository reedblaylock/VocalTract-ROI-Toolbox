classdef Increment < vt.Component.Button & vt.Action.Dispatcher
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
			
			this@vt.Component.Button(parent, label);
			this@vt.Action.Dispatcher();
			this.action.data = p.Results.incrementValue;
		
			this.setCallback();
		end
	end
	
end

