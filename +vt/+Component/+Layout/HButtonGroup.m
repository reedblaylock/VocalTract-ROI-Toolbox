classdef HButtonGroup < vt.Component.Layout
	methods
		function this = HButtonGroup(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout.HButtonGroup'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uix2.HButtonGroup( ...
				'Parent', parent.handle ...
			);
		end
	end
	
end

