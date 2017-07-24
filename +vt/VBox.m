classdef VBox < vt.LayoutComponent
	methods
		function this = VBox(parent, varargin)
			this@vt.LayoutComponent(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.VBox'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uix.VBox( ...
				'Parent', parent.handle ...
			);
		end
	end
	
end
