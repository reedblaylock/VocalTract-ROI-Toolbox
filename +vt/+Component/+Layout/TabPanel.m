classdef TabPanel < vt.Component.Layout
	methods
		function this = TabPanel(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout.TabPanel'));
			p.addParent();
			parse(p, this, parent);
			
% 			this.handle = uiextras.TabPanel( ...
% 				'Parent', p.Results.parent.handle ...
% 			);
			if ( this.isOldMatlabVersion() )
				this.handle = uiextras.TabPanel( ...
					'Parent', p.Results.parent.handle ...
				);
			else
				this.handle = uix.TabPanel( ...
					'Parent', p.Results.parent.handle ...
				);
			end
		end
	end
end

