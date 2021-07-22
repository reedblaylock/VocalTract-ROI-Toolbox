classdef RegionShape < redux.Component.Popup & redux.State.Listener & redux.Action.Dispatcher
	properties
		currentRegion
		video
	end
	
	methods
		function this = RegionShape(parent)
			this@redux.Component.Popup(parent);
			
			this.setParameters( ...
				'String', {'Circle', 'Rectangle', 'Correlated'}, ...
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
			
			if isempty(this.currentRegion)
				config = vt.Config();
				this.setCurrentPopupString(config.region.shape);
			else
				this.setCurrentPopupString(this.currentRegion.shape);
			end
		end
		
		function [] = onVideoChange(this, state)
			this.video = state.video;
		end
		
		function [] = dispatchAction(this, ~, ~)
			str = this.getCurrentPopupString();
% 			action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
% 			action.prepare(this.currentRegion, 'shape', str, this.video);
% 			action.dispatch();
            
            switch(str)
                case {'Correlated'}
                    action = this.actionFactory.actions.CHANGE_MULTIPLE_REGION_PARAMETERS;
                    action.prepare(this.currentRegion, {'shape', 'type'}, {str, 'Average'}, this.video);
                otherwise
                    action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
                    action.prepare(this.currentRegion, 'shape', str, this.video);
            end
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

