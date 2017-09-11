classdef Copy < vt.Component.MenuItem & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.Copy
	end
	
	methods
		function this = Copy(parent, label)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			parse(p, parent, label);
			
			this@vt.Component.MenuItem(p.Results.parent, p.Results.label);
			
% 			this@vt.Action.Dispatcher();
			
			this.setCallback();
		end
	end
	
end

