classdef HButtonBox < vt.Component.Layout
	methods
		function this = HButtonBox(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout.HButtonBox'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uiextras.HButtonBox( ...
				'Parent', parent.handle ...
			);
% 			if ( this.isOldMatlabVersion() )
% 				this.handle = guilayouttoolbox.old.layout.uiextras.HButtonBox( ...
% 					'Parent', parent.handle ...
% 				);
% 			else
% 				this.handle = guilayouttoolbox.new.layout.uix.HButtonBox( ...
% 					'Parent', parent.handle ...
% 				);
% 			end
		end
	end
	
end

