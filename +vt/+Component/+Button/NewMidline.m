classdef NewMidline < vt.Component.Button & vt.Action.Dispatcher & vt.State.Listener
	properties
		actionType = @vt.Action.NewMidline
	end
	
	methods
		function this = NewMidline(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			
			this.setCallback();
		end
		
		function [] = onVideoChange(this, ~)
			this.setParameters('Enable', 'on');
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case {'midlineNew', 'midlineEdit'}
					this.setParameters('Enable', 'off');
				otherwise
					this.setParameters('Enable', 'on');
			end
		end
	end
	
end

