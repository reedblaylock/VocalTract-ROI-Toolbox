classdef ShowFill < vt.Component.Checkbox
	properties
		actionType = @vt.Action.ToggleShowFill
	end
	
	methods
		function this = ShowFill(parent, label)
			this@vt.Component.Checkbox(parent, label);
		end
	end
	
end

