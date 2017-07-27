classdef TextBox < vt.Component
	properties
	end
	
	methods
		function this = TextBox(parent, string)
			p = vt.InputParser;
			p.addParent();
			p.addOptional('string', '', @ischar);
			p.parse(parent, string);
			
			this.handle = uicontrol( ...
				p.Results.parent.handle, ...
				'Style', 'edit', ...
				'String', p.Results.string ...
			);
		end
	end
	
end

