classdef RegionShape < vt.Component.Popup & vt.State.Listener & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.ChangeRegionShape
	end
	
	methods
		function this = RegionShape(parent)
			this@vt.Component.Popup(parent);
			
			this.setParameters( ...
				'String', {'Circle', 'Rectangle', 'Statistically-generated', 'Custom'}, ...
				'Enable', 'off' ...
			);
		
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
		
		function [] = dispatchAction(this, ~, ~)
			str = this.getCurrentPopupString();
			this.action.dispatch(str);
		end
	end
end

