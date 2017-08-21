classdef HBox < vt.Component.Layout
	methods
		% It seems like I should be able to get away without a constructor here,
		% but MATLAB doesn't seem to like it. Maybe it has something to do with
		% varargin?
		function this = HBox(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout.HBox'));
			p.addParent();
			parse(p, this, parent);
			
			this.handle = uiextras.HBox( ...
				'Parent', parent.handle ...
			);
% 			if ( this.isOldMatlabVersion() )
% 				this.handle = guilayouttoolbox.old.layout.uiextras.HBox( ...
% 					'Parent', parent.handle ...
% 				);
% 			else
% 				this.handle = guilayouttoolbox.new.layout.uix.HBox( ...
% 					'Parent', parent.handle ...
% 				);
% 			end
		end
	end
	
end

