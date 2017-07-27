classdef MenuItem < vt.Component
	methods
		function this = MenuItem(parent, label)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			p.parse(parent, label);
			
			this.handle = uimenu( ...
				p.Results.parent.handle, ...
				'Label', p.Results.label ...
			);
		end
	end
	
end

