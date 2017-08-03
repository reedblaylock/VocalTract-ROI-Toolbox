classdef Radius < vt.Component.TextBox & vt.State.Listener & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.ChangeRegionRadius;
	end
	
	methods
		function this = Radius(parent)
			p = vt.InputParser();
			p.addParent();
			p.parse(parent);
			
			this@vt.Component.TextBox(parent);
			this.setParameters('String', '3');
			
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
		
		function [] = onCurrentRegionChange(this, state)
			this.setParameters('String', num2str(state.currentRegion.radius));
		end
		
		function [] = dispatchAction(this, ~, ~)
			radius = str2double(this.getParameter('String'));
			this.action.dispatch(radius);
		end
	end
	
end