classdef IncrementButton < vt.Button & vt.ActionDispatcherWithData
	events
		INCREMENT
	end
	
	methods
		function this = IncrementButton(parent, label, incrementValue)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			p.addRequired('incrementValue', @isnumeric);
			p.parse(parent, label, incrementValue);
			
			this@vt.Button(parent, label);
		
			this.setData(incrementValue);
		
			this.setCallback();
		end
	end
	
end

