classdef ShowOutline < redux.Component.Checkbox & redux.State.Listener & redux.Action.Dispatcher
	properties
		currentRegion
	end
	
	methods
		function this = ShowOutline(parent, label)
			this@redux.Component.Checkbox(parent, label);
			
			this.setCallback();
		end
		
		function [] = onCurrentRegionChange(this, state)
			this.currentRegion = [];
			
			regions = state.regions;
			for iRegion = 1:numel(regions)
				if regions{iRegion}.id == state.currentRegion
					this.currentRegion = regions{iRegion};
					break;
				end
			end
			
			if isempty(this.currentRegion)
				config = vt.Config();
				this.setParameters('Value', config.region.showOutline);
			else
				this.setParameters('Value', this.currentRegion.showOutline);
			end
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case 'region'
					this.setParameters('Enable', 'on');
				otherwise
					this.setParameters('Enable', 'off');
			end
		end
		
		function [] = dispatchAction(this, ~, ~)
			value = this.getParameter('Value');
			action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
			action.prepare(this.currentRegion, 'showOutline', value);
			action.dispatch();
		end
		
		function [] = onRegionsChange(this, state)
			for iRegion = 1:numel(state.regions)
				if state.regions{iRegion}.id == state.currentRegion
					this.currentRegion = state.regions{iRegion};
					break;
				end
			end
		end
	end
	
end

