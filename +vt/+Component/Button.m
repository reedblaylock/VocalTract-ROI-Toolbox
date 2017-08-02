classdef Button < vt.Component
	% This button won't do anything. If you want to make a button that does
	% something, you'll have to make a subclass that inherits from vt.Button and
	% vt.ActionDispatcher{With|Without}Data.
	
	methods
		function this = Button(parent, label)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			p.parse(parent, label);
			
			this.handle = uicontrol(...
				'Parent', p.Results.parent.handle, ...
				'String', p.Results.label, ...
				'Enable', 'off' ...
			);
		end
	end
	
end

