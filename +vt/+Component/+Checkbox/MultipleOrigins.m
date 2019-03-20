classdef MultipleOrigins < redux.Component.Checkbox
	properties
		actionType = @redux.Action.ToggleMultipleOrigins
	end
	
	methods
		function this = MultipleOrigins(parent, label)
			this@redux.Component.Checkbox(parent, label);
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

