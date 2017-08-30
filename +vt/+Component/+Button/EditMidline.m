classdef EditMidline < vt.Component.Button & vt.Action.Dispatcher & vt.State.Listener
	properties
		actionType = @vt.Action.EditMidline
	end
	
	methods
		function this = EditMidline(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			this.setParameters('Enable', 'off');
			
			this.setCallback();
		end
		
% 		function [] = onCurrentRegionChange(this, state)
% 			if(isfield(state.currentRegion, 'id') && ~isempty(state.currentRegion.id))
% 				this.setParameters('Enable', 'on');
% 			else
% 				this.setParameters('Enable', 'off');
% 			end
% 		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case ''
					% The edit button can only be on when nothing is currently
					% being edited, and there are midline points available to be
					% edited
					if(isfield(state.midline, 'points') && ~isempty(state.midline.points))
						this.setParameters('Enable', 'on');
					else
						this.setParameters('Enable', 'off');
					end
				otherwise
					this.setParameters('Enable', 'off');
			end
		end
	end
	
end

