classdef HBox < vt.LayoutComponent
	methods
		% It seems like I should be able to get away without a constructor here,
		% but MATLAB doesn't seem to like it. Maybe it has something to do with
		% varargin?
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

