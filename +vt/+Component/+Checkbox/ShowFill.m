classdef ShowFill < vt.Component.Checkbox
	properties
		actionType = @vt.Action.ToggleShowFill
	end
	
	methods
		function this = ShowFill(parent, label)
			this@vt.Component.Checkbox(parent, label);
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case 'region'
					this.setParameters('Enable', 'on');
				otherwise
					this.setParameters('Enable', 'off');
			end
		end
	end
	
end

