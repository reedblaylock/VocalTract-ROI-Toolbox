classdef Panel < vt.Component.Layout
	methods
		function this = Panel(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent);
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
			this.handle = uix.Panel( ...
				'Parent', p.Results.parent.handle ...
			);
		end
	end
end

