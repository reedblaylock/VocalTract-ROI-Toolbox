classdef ShowOrigin < vt.Component.Checkbox
	properties
		actionType = @vt.Action.ToggleShowOrigin
	end
	
	methods
		function this = ShowOrigin(parent, label)
			this@vt.Component.Checkbox(parent, label);
		end
	end
	
end

