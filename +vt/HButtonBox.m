classdef HButtonBox < vt.LayoutComponent
	properties
	end
	
	methods
		function this = HButtonBox(parent, varargin)
			this@vt.LayoutComponent(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.HButtonBox'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uix.HButtonBox( ...
				'Parent', parent.handle ...
			);
		end
	end
	
end

