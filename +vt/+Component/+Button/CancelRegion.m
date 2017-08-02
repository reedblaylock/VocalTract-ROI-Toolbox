classdef CancelRegion < vt.Component.Button & vt.State.Listener & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.CancelRegionChange
	end
	
	methods
		function this = CancelRegion(parent, label)
			this@vt.Component.Button(parent, label);
			
			this.setCallback();
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

