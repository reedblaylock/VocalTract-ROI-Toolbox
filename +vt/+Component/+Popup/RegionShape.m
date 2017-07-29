classdef RegionShape < vt.Component.Popup
	properties
		actionType = @vt.Action.ChangeRegionShape
	end
	
	methods
		function this = RegionShape(parent)
			this@vt.Component.Popup(parent);
			
			this.setParameters( ...
				'String', {'Circle', 'Rectangle', 'Statistically-generated', 'Custom'} ...
			);
		
% 			this.setCallback();
		end
	end
end

