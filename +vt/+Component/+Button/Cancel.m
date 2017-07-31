classdef Cancel < vt.Component.Button
	properties
		actionType = @vt.Action.Cancel
	end
	
	methods
		function this = Cancel(parent, label)
			this@vt.Component.Button(parent, label);
			
% 			this.setCallback();
		end
	end
	
end

