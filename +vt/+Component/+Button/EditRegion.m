classdef EditRegion < vt.Component.Button & vt.Action.Dispatcher & vt.State.Listener
	methods
		function this = EditRegion(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			this.setParameters('Enable', 'off');
			
			this.setCallback();
		end
		
		function [] = onCurrentRegionChange(this, state)
			if ~isempty(state.currentRegion)
				this.setParameters('Enable', 'on');
			else
				this.setParameters('Enable', 'off');
			end
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case ''
					% The edit button can only be on when nothing is currently
					% being edited, and there are regions available to be edited
					if(~(isempty(fieldnames(this.state.regions)) || ~numel(this.state.regions)))
						this.setParameters('Enable', 'on');
					else
						this.setParameters('Enable', 'off');
					end
				otherwise
					this.setParameters('Enable', 'off');
			end
		end
		
		function [] = dispatchAction(this, ~, ~)
			action = this.actionFactory.actions.EDIT_REGION;
			action.prepare();
			action.dispatch();
		end
	end
	
end

