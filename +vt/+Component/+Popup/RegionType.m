classdef RegionType < vt.Component.Popup & vt.State.Listener
	properties
		actionType = @vt.Action.ChangeRegionType
	end
	
	methods
		function this = RegionType(parent)
			this@vt.Component.Popup(parent);
			
			this.setParameters( ...
				'String', {'Average'} ...
			);
		
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

