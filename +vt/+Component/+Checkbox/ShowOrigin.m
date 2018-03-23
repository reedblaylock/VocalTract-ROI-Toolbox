classdef ShowOrigin < vt.Component.Checkbox & vt.State.Listener & vt.Action.Dispatcher
	properties
		currentRegion
	end
	
	methods
		function this = ShowOrigin(parent, label)
			this@vt.Component.Checkbox(parent, label);
			
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
			
			if ~isempty(this.currentRegion)
				this.setParameters('Value', this.currentRegion.showOrigin);
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
			action.prepare(this.currentRegion, 'showOrigin', value);
			action.dispatch();
		end
	end
	
end

