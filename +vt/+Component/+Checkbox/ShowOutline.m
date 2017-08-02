classdef ShowOutline < vt.Component.Checkbox & vt.State.Listener & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.ToggleShowOutline
	end
	
	methods
		function this = ShowOutline(parent, label)
			this@vt.Component.Checkbox(parent, label);
			
			this.setCallback();
		end
		
		function [] = onCurrentRegionChange(this, state)
			this.setParameters('Value', state.currentRegion.showOutline);
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case 'region'
					this.setParameters('Enable', 'on');
				otherwise
					this.setParameters('Enable', 'off');
			end
		end
		
		function [] = dispatchAction(this, ~, ~)
			value = this.getParameter('Value');
			this.action.dispatch(value);
		end
	end
	
end

