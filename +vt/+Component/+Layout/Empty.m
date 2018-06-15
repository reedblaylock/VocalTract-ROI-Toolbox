classdef Empty < vt.Component.Layout
	methods
		function this = Empty(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
% 			this.handle = uiextras.Empty( ...
% 				'Parent', p.Results.parent.handle ...
% 			);
		
			if vt.Config.isOldMatlabVersion()
				% Use the old version of the GUI Layout Toolbox
				this.handle = uiextras.Empty( ...
					'Parent', p.Results.parent.handle ...
				);
			else
				% Use the new version of the GUI Layout Toolbox
				this.handle = uix.Empty( ...
					'Parent', p.Results.parent.handle ...
				);
			end
		end
	end
end

