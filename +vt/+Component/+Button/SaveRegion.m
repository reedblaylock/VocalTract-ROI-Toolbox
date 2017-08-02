classdef SaveRegion < vt.Component.Button & vt.State.Listener
	properties
		actionType = @vt.Action.SaveRegion
	end
	
	methods
		function this = SaveRegion(parent, label)
			this@vt.Component.Button(parent, label);
			
% 			this.setCallback();
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

