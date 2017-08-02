classdef Slider < vt.Component
	methods
		function this = Slider(parent)
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
			this.handle = uicontrol(...
				'Parent', p.Results.parent.handle, ...
				'Style', 'slider', ...
				'Enable', 'off' ...
			);
		end
	end
end

