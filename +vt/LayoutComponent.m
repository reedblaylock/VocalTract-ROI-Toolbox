classdef (Abstract) LayoutComponent < vt.Component
	
	properties
	end
	
	methods
		function this = LayoutComponent(parent, varargin)
			p = vt.InputParser;
			p.KeepUnmatched = true;
			p.addParent();
			parse(p, parent, varargin{:});
			
			this.construct(p.Results.parent);
			
			% Could instead call this.setParameters(varargin{:});
			set(this.handle, varargin{:});
		end
	end
	
	methods (Access = protected)
		[] = construct(this, parent);
	end
	
end

