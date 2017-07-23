classdef Container < vt.Component
	% This function is a wrapper for uicontainer, a native MATLAB GUI
	% function/component whose purpose is to be a transparent wrapper for more
	% concrete components like axes that are difficult to work with (e.g.
	% resize).
	
	properties
	end
	
	methods
		function this = Container(parent, varargin)
			p = vt.InputParser;
			p.addParent();
			p.addOptionalAction();
			p.parse(parent, varargin{:});
			
			this.handle = uicontainer(...
				'Parent', p.Results.parent.handle ...
			);
			
			if(~isempty(p.Results.action))
				this.setCallback( p.Results.action );
			end
		end
	end
	
end

