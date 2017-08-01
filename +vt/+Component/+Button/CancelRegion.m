classdef CancelRegion < vt.Component.Button
	properties
		actionType = @vt.Action.CancelRegionChange
	end
	
	methods
		function this = CancelRegion(parent, label)
			this@vt.Component.Button(parent, label);
			
% 			this.setCallback();
		end
	end
	
end

