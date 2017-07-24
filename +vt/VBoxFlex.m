classdef VBoxFlex < vt.LayoutComponent
	methods
		function this = VBoxFlex(parent, varargin)
			this@vt.LayoutComponent(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.VBoxFlex'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uix.VBoxFlex( ...
				'Parent', parent.handle ...
			);
		end
	end
	
end

