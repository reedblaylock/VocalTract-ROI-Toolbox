classdef Save < vt.Component.Button
	properties
		actionType = @vt.Action.Save
	end
	
	methods
		function this = Save(parent, label)
			this@vt.Component.Button(parent, label);
			
% 			this.setCallback();
		end
	end
	
end

