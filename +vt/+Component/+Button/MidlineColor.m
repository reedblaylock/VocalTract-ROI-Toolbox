classdef MidlineColor < vt.Component.Button & vt.Action.Dispatcher & vt.State.Listener
	properties
		actionType = @vt.Action.ChangeMidlineColor
	end
	
	methods
		function this = MidlineColor(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			
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
				case 'midlineEdit'
					this.setParameters('Enable', 'on');
				otherwise
					this.setParameters('Enable', 'off');
			end
		end
	end
	
end

