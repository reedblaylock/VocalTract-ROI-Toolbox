classdef VButtonBox < vt.LayoutComponent
	methods
		function this = VButtonBox(parent, varargin)
			this@vt.LayoutComponent(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.VButtonBox'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uix.VButtonBox( ...
				'Parent', parent.handle ...
			);
		end
	end
	
end
