classdef Popup < vt.Component
	methods
		function this = Popup(parent)
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
			this.handle = uicontrol( ...
				'Parent', p.Results.parent.handle, ...
				'Style', 'popup', ...
				'Enable', 'off' ...
			);
		end
	end
	
end

