classdef SaveRegion < vt.Component.Button & vt.State.Listener & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.SaveRegion
	end
	
	methods
		function this = SaveRegion(parent, label)
			this@vt.Component.Button(parent, label);
			
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
			if(this.checkRegionIsSaved(state) || ~this.checkRegionHasRequiredProperties(state))
				this.setParameters('Enable', 'off');
			else
				this.setParameters('Enable', 'on');
			end
		end
		
		function b = checkRegionIsSaved(~, state)
			b = false;
			
			if(isempty(fieldnames(state.regions)) || ~numel(state.regions))
				% There are no regions in state.regions
				return;
			end
			
			idx = [state.regions.id] == state.currentRegion.id;
			if(~any(idx))
				% The current region's id is not in state.regions
				return;
			end
			
			if(isequal(state.currentRegion, state.regions(idx)))
				b = true;
			end
		end
		
		function b = checkRegionHasRequiredProperties(~, state)
			b = true;
			
			if(isempty(state.currentRegion.name) || isempty(state.currentRegion.origin))
				b = false;
			end
		end
		
% 		function [] = dispatchAction(this, ~, ~)
% 			try
% 				this.action.dispatch();
% 				
% 				% TODO: Find a way to check whether the region was successfully
% 				% saved, and put the code for that in this.checkIsSaved. Disabling
% 				% the button immediately seems premature. The try/catch block might
% 				% help, though.
% 				this.setParameters('Enable', 'off');
% 			catch excp
% 				this.log.exception(excp);
% 			end
% 		end
	end
	
end

