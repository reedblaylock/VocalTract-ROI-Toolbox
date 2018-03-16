classdef RegionColor < vt.Component.Button & vt.Action.Dispatcher & vt.State.Listener
	properties
		currentRegion
	end
	
	methods
		function this = RegionColor(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			
			this.setCallback();
		end
		
		function [] = dispatchAction(this, ~, ~)
			color = uisetcolor();
			if(~color)
				return;
			end
			
			action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
			action.prepare(this.currentRegion, 'color', color);
			this.action.dispatch();
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
			this.currentRegion = [];
			
			regions = state.regions;
			for iRegion = 1:numel(regions)
				if regions{iRegion}.id == state.currentRegion
					this.currentRegion = regions{iRegion};
					break;
				end
			end
		end
	end
	
end

