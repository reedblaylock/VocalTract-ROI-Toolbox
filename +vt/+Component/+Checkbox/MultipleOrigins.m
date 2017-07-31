classdef MultipleOrigins < vt.Component.Checkbox
	properties
		actionType = @vt.Action.ToggleMultipleOrigins
	end
	
	methods
		function this = MultipleOrigins(parent, label)
			this@vt.Component.Checkbox(parent, label);
		end
	end
	
end

