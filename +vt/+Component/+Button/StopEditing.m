classdef StopEditing < vt.Component.Button & vt.State.Listener & vt.Action.Dispatcher
	properties
		currentRegion
	end
	
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
		
		function [] = onCurrentRegionChange(this, state)
			regions = state.regions;
			for iRegion = 1:numel(regions)
				if regions{iRegion}.id == state.currentRegion
					this.currentRegion = regions{iRegion};
					break;
				end
			end
		end
		
		function [] = onRegionsChange(this, state)
			for iRegion = 1:numel(state.regions)
				if state.regions{iRegion}.id == state.currentRegion
					this.currentRegion = state.regions{iRegion};
					break;
				end
			end
		end
		
		function [] = dispatchAction(this, source, eventData)
			if isempty(this.currentRegion.origin)
				action = this.actionFactory.actions.DELETE_REGION;
				action.prepare(this.currentRegion.id);
			else
				action = this.actionFactory.actions.STOP_EDITING;
				action.prepare();
			end
			
			action.dispatch();
		end
	end
	
end

