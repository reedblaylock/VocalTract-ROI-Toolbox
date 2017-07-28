classdef VButtonGroup < vt.Component.Layout
	methods
		function this = VButtonGroup(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout.VButtonGroup'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uix2.VButtonGroup( ...
				'Parent', parent.handle ...
			);
		end
	end
	
end

