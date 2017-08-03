classdef MinimumPixels < vt.Component.TextBox %& vt.State.Listener
	properties
		actionType = @vt.Action.ChangeMinimumPixels;
	end
	
	methods
		function this = MinimumPixels(parent)
			p = vt.InputParser();
			p.addParent();
			p.parse(parent);
			
			this@vt.Component.TextBox(parent);
			this.setParameters('Enable', 'off');
			
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