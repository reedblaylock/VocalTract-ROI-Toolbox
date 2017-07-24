classdef Container < vt.Component
	% This function is a wrapper for uicontainer, a native MATLAB GUI
	% function/component whose purpose is to be a transparent wrapper for more
	% concrete components like axes that are difficult to work with (e.g.
	% resize).
	
	methods
		function this = Container(parent)
			p = vt.InputParser;
			p.addParent();
			p.parse(parent);
			
			this.handle = uicontainer(...
				'Parent', p.Results.parent.handle ...
			);
		end
	end
	
end

