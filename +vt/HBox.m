classdef HBox < vt.LayoutComponent
	properties
	end
	
	methods
		function this = HBox(parent, varargin)
			this@vt.LayoutComponent(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.HBox'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uix.HBox( ...
				'Parent', parent.handle ...
			);
		end
	end
	
end

