classdef SaveRegion < vt.Component.Button
	properties
		actionType = @vt.Action.SaveRegion
	end
	
	methods
		function this = SaveRegion(parent, label)
			this@vt.Component.Button(parent, label);
			
% 			this.setCallback();
		end
	end
	
end

