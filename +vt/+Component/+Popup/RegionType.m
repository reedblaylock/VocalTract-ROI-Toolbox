classdef RegionType < vt.Component.Popup & vt.State.Listener & vt.Action.Dispatcher
	properties
		currentRegion
		video
	end
	
	methods
		function this = RegionType(parent)
			this@vt.Component.Popup(parent);
			
			this.setParameters( ...
				'String', {'Average', 'Binary'}, ...
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
				this.setCurrentPopupString(config.region.type);
			else
				this.setCurrentPopupString(this.currentRegion.type);
			end
		end
		
		function [] = onVideoChange(this, state)
			this.video = state.video;
		end
		
		function [] = dispatchAction(this, ~, ~)
			str = this.getCurrentPopupString();
			action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
			action.prepare(this.currentRegion, 'type', str, this.video);
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

