classdef RegionShape < vt.Component.Popup & vt.State.Listener & vt.Action.Dispatcher
	properties
		currentRegion
		video
	end
	
	methods
		function this = RegionShape(parent)
			this@vt.Component.Popup(parent);
			
			this.setParameters( ...
				'String', {'Circle', 'Rectangle'}, ...
				'Enable', 'off' ...
			);
			% 'String', {'Circle', 'Rectangle', 'Statistically-generated', 'Custom'}, ...
		
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
			
			if ~isempty(this.currentRegion)
				this.setCurrentPopupString(this.currentRegion.shape);
			end
		end
		
		function [] = onVideoChange(this, state)
			this.video = state.video;
		end
		
		function [] = dispatchAction(this, ~, ~)
			str = this.getCurrentPopupString();
			action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
			action.prepare(this.currentRegion, 'shape', str, this.video);
			this.action.dispatch();
		end
	end
end

