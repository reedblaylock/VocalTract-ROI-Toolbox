classdef NewRegion < vt.Component.Button & vt.Action.Dispatcher & vt.State.Listener
	methods
		function this = NewRegion(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			
			this.setCallback();
		end
		
		function [] = onVideoChange(this, ~)
			this.setParameters('Enable', 'on');
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case 'region'
					this.setParameters('Enable', 'off');
				otherwise
					this.setParameters('Enable', 'on');
			end
		end
		
		function [] = dispatchAction(this, ~, ~)
			action = this.actionFactory.actions.NEW_REGION;
			action.prepare();
			action.dispatch();
		end
	end
	
end

