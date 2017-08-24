classdef VButtonBox < vt.Component.Layout
	methods
		function this = VButtonBox(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout.VButtonBox'));
			p.addParent();
			parse(p, this, parent);
			
% 			this.handle = uiextras.VButtonBox( ...
% 				'Parent', parent.handle ...
% 			);
			if ( this.isOldMatlabVersion() )
				this.handle = uiextras.VButtonBox( ...
					'Parent', parent.handle ...
				);
			else
				this.handle = uix.VButtonBox( ...
					'Parent', parent.handle ...
				);
			end
		end
	end
	
end

