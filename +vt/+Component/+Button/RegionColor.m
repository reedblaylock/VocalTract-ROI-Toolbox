classdef RegionColor < vt.Component.Button & vt.Action.Dispatcher & vt.State.Listener
	properties
		actionType = @vt.Action.ChangeRegionColor
	end
	
	methods
		function this = RegionColor(parent, label)
			this@vt.Component.Button(parent, label);
			
			this.setCallback();
		end
		
		function [] = dispatchAction(this, ~, ~)
			color = uisetcolor();
			if(~color)
				return;
			end
			
			this.action.dispatch(color);
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

