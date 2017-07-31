classdef MinimumPixels < vt.Component.TextBox
	properties
		actionType = @vt.Action.ChangeMinimumPixels;
	end
	
	methods
		function this = MinimumPixels(parent)
			p = vt.InputParser();
			p.addParent();
			p.parse(parent);
			
			this@vt.Component.TextBox(parent);
			this.setParameters('Enable', 'off');
			
% 			this.setCallback();
		end
	end
	
end