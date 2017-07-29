classdef RegionType < vt.Component.Popup
	properties
		actionType = @vt.Action.ChangeRegionType
	end
	
	methods
		function this = RegionType(parent)
			this@vt.Component.Popup(parent);
			
			this.setParameters( ...
				'String', {'Average'} ...
			);
		
% 			this.setCallback();
		end
	end
end

