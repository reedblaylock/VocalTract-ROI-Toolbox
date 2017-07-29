classdef ListBox < vt.Component
	methods
		function this = ListBox(parent)
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
			this.handle = uicontrol( ...
				'Parent', p.Results.parent.handle, ...
				'Style', 'listbox' ...
			);
		end
	end
	
end

