classdef Container < vt.Component
	% This function is a wrapper for uicontainer, a native MATLAB GUI
	% function/component whose purpose is to be a transparent wrapper for more
	% concrete components like axes that are difficult to work with (e.g.
	% resize).
	
	methods
		function this = Container(parent, varargin)
			p = vt.InputParser;
			p.addParent();
			p.addParameter('Tag', '', @ischar);
			p.parse(parent, varargin{:});
			
			this.handle = uicontainer(...
				'Parent', p.Results.parent.handle ...
			);
		
			if(isfield(p.Results, 'Tag'))
				this.setParameters('Tag', p.Results.Tag);
			end
		end
	end
	
end

