classdef TextBox < vt.Component
	properties
	end
	
	methods
		function this = TextBox(parent, varargin)
			p = vt.InputParser;
			p.KeepUnmatched = true;
			p.addParent();
			p.addOptional('string', '', @ischar);
			p.parse(parent, varargin{:});
			
			this.handle = uicontrol( ...
				p.Results.parent.handle, ...
				'Style', 'edit', ...
				'String', p.Results.string ...
			);
		
			if(numel(fieldnames(p.Unmatched)))
				this.setParameters(varargin{:});
			end
		end
	end
	
end

