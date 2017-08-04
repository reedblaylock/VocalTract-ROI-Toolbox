classdef DeleteRegion < vt.Component.Button & vt.State.Listener & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.DeleteRegion
% 		regionId
	end
	
	methods
		function this = DeleteRegion(parent, label, varargin)
			this@vt.Component.Button(parent, label, varargin{:});
			
			this.setCallback();
		end
		
		function [] = onCurrentRegionChange(this, state)
			if(isfield(state.currentRegion, 'id') && ~isempty(state.currentRegion.id))
				this.setParameters('Enable', 'on');
			else
				this.setParameters('Enable', 'off');
			end
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case 'region'
% 					this.regionId = state.currentRegion.id;
					this.setParameters('Enable', 'on');
				otherwise
% 					this.regionId = [];
					this.setParameters('Enable', 'off');
			end
		end
		
% 		function [] = dispatchAction(this, ~, ~)
% 			this.action.dispatch(this.regionId);
% 		end
	end
	
end

