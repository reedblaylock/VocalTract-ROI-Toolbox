classdef ShowOutline < vt.Component.Checkbox
	properties
		actionType = @vt.Action.ToggleShowOutline
	end
	
	methods
		function this = ShowOutline(parent, label)
			this@vt.Component.Checkbox(parent, label);
		end
	end
	
end

