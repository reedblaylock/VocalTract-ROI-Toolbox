classdef CancelMidline < vt.Component.Button & vt.State.Listener & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.CancelMidlineChange
	end
	
	methods
		function this = CancelMidline(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			
			this.setCallback();
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

