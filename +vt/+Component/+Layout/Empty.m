classdef Empty < vt.Component.Layout
	methods
		function this = Empty(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
			this.handle = uix.Empty( ...
				'Parent', p.Results.parent.handle ...
			);
		end
	end
end

