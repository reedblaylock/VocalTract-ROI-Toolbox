classdef VBox < vt.Component.Layout
	methods
		function this = VBox(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout.VBox'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uiextras.VBox( ...
				'Parent', parent.handle ...
			);
% 			if ( this.isOldMatlabVersion() )
% 				this.handle = guilayouttoolbox.old.layout.uiextras.VBox( ...
% 					'Parent', parent.handle ...
% 				);
% 			else
% 				this.handle = guilayouttoolbox.new.layout.uix.VBox( ...
% 					'Parent', parent.handle ...
% 				);
% 			end
		end
	end
	
end

