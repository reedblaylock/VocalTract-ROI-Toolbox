classdef StopEditing < vt.Component.Button & vt.State.Listener & vt.Action.Dispatcher
	methods
		function this = StopEditing(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			
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
		
		function [] = dispatchAction(this, source, eventData)
			action = this.actionFactory.actions.STOP_EDITING;
			action.prepare();
			action.dispatch();
		end
	end
	
end

