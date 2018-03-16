classdef DeleteRegion < vt.Component.Button & vt.State.Listener & vt.Action.Dispatcher
	properties
		regionId
	end
	
	methods
		function this = DeleteRegion(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			
			this.setCallback();
		end
		
		function [] = onCurrentRegionChange(this, state)
			this.regionId = state.currentRegion;
% 			if(isfield(state.currentRegion, 'id') && ~isempty(state.currentRegion.id))
% 				this.setParameters('Enable', 'on');
% 			else
% 				this.setParameters('Enable', 'off');
% 			end
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case 'region'
% 					this.currentRegion = state.currentRegion;
					this.setParameters('Enable', 'on');
				otherwise
% 					this.currentRegion = [];
					this.setParameters('Enable', 'off');
			end
		end
		
		function [] = dispatchAction(this, ~, ~)
			action = this.actionFactory.actions.DELETE_REGION;
			action.prepare(this.regionId);
			action.dispatch();
		end
	end
	
end

