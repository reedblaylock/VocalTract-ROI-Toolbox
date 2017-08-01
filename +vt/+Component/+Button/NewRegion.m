classdef NewRegion < vt.Component.Button & vt.Action.Dispatcher & vt.State.Listener
	properties
		actionType = @vt.Action.NewRegion
	end
	
	methods
		function this = NewRegion(parent, label)
			this@vt.Component.Button(parent, label);
			
			this.setCallback();
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case 'region'
					this.setParameters('Enable', 'off');
				case ''
					this.setParameters('Enable', 'on');
				otherwise
					this.setParameters('Enable', 'on');
			end
		end
	end
	
end

