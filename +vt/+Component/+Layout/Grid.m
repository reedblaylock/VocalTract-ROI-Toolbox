classdef Grid < vt.Component.Layout
	methods
		function this = Grid(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
			this.handle = uix.Grid( ...
				'Parent', p.Results.parent.handle ...
			);
		end
	end
end

