classdef Tau < vt.Component.TextBox %& vt.State.Listener
	properties
		actionType = @vt.Action.ChangeTau;
	end
	
	methods
		function this = Tau(parent)
			p = vt.InputParser();
			p.addParent();
			p.parse(parent);
			
			this@vt.Component.TextBox(parent);
			
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