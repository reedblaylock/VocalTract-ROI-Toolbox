classdef DeleteRegion < vt.Component.Button
	properties
		actionType = @vt.Action.DeleteRegion
	end
	
	methods
		function this = DeleteRegion(parent, label)
			this@vt.Component.Button(parent, label);
			
% 			this.setCallback();
		end
	end
	
end

