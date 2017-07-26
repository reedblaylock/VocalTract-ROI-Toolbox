classdef Text < vt.Component
	properties
	end
	
	methods
		function this = Text(parent)
			p = vt.InputParser;
			p.addParent();
			p.parse(parent);
			
			this.handle = uicontrol( ...
				p.Results.parent.handle, ...
				'Style', 'text' ...
			);
		end
	end
	
end

