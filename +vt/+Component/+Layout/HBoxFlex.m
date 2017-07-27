classdef HBoxFlex < vt.Component.Layout
	methods
		function this = HBoxFlex(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.HBoxFlex'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uix.HBoxFlex( ...
				'Parent', parent.handle ...
			);
		end
	end
	
end

