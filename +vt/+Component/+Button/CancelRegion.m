classdef CancelRegion < vt.Component.Button & vt.State.Listener & vt.Action.Dispatcher
	properties
		action
	end
	
	methods
		function this = CancelRegion(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			
			this.action = this.actionFactory.get('STOP_EDITING');
			
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
	end
	
end

