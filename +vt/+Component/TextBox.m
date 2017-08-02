classdef TextBox < vt.Component
	properties
	end
	
	methods
		function this = TextBox(parent, varargin)
			p = vt.InputParser;
			p.addParent();
			p.addOptional('string', '', @ischar);
			p.parse(parent, varargin{:});
			
			this.handle = uicontrol( ...
				p.Results.parent.handle, ...
				'Style', 'edit', ...
				'String', p.Results.string, ...
				'Enable', 'off' ...
			);
		end
	end
	
end

