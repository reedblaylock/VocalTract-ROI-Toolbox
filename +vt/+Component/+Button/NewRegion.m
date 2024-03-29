classdef NewRegion < redux.Component.Button & redux.Action.Dispatcher & redux.State.Listener
    
    properties
        regions
    end
    
	methods
		function this = NewRegion(parent, label, varargin)
			this@redux.Component.Button(parent, label, varargin{:});
			
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
        
        function [] = onRegionsChange(this, state)
            this.regions = state.regions;
        end
		
		function [] = dispatchAction(this, ~, ~)
			action = this.actionFactory.actions.NEW_REGION;
			action.prepare(this.regions);
			action.dispatch();
		end
	end
	
end

