classdef SnapToMidline < vt.Component.Checkbox
	properties
		actionType = @vt.Action.ToggleSnapToMidline
	end
	
	methods
		function this = SnapToMidline(parent, label)
			this@vt.Component.Checkbox(parent, label);
		end
	end
	
end

