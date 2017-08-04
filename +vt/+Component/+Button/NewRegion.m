classdef NewRegion < vt.Component.Button & vt.Action.Dispatcher & vt.State.Listener
	properties
		actionType = @vt.Action.NewRegion
	end
	
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
	end
	
end

