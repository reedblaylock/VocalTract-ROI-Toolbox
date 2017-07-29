classdef RegionName < vt.Component.TextBox
	properties
		actionType = @vt.Action.ChangeRegionName;
		maxFrame
	end
	
	methods
		function this = RegionName(parent)
			p = vt.InputParser();
			p.addParent();
			p.parse(parent);
			
			this@vt.Component.TextBox(parent);
			this.setParameters('Enable', 'off');
			
% 			this.setCallback();
		end
	end
	
end