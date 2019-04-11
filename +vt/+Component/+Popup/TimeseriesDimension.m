classdef TimeseriesDimension < redux.Component.Popup & redux.State.Listener & redux.Action.Dispatcher
	properties
		currentRegion
		video
	end
	
	methods
		function this = TimeseriesDimension(parent)
			this@redux.Component.Popup(parent);
			
			this.setParameters( ...
				'String', {'x', 'y'}, ...
				'Enable', 'off' ...
			);
		
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
				this.setCurrentPopupString(config.region.timeseriesDimension);
			else
				this.setCurrentPopupString(this.currentRegion.timeseriesDimension);
			end
		end
		
		function [] = onVideoChange(this, state)
			this.video = state.video;
		end
		
		function [] = dispatchAction(this, ~, ~)
			str = this.getCurrentPopupString();
			action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
			action.prepare(this.currentRegion, 'timeseriesDimension', str, this.video);
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

