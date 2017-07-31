classdef SearchRadius < vt.Component.TextBox
	properties
		actionType = @vt.Action.ChangeSearchRadius;
	end
	
	methods
		function this = SearchRadius(parent)
			p = vt.InputParser();
			p.addParent();
			p.parse(parent);
			
			this@vt.Component.TextBox(parent);
			this.setParameters('Enable', 'off');
			
% 			this.setCallback();
		end
	end
	
end