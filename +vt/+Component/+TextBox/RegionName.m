classdef RegionName < vt.Component.TextBox & vt.Action.Dispatcher & vt.State.Listener
	properties
		actionType = @vt.Action.ChangeRegionName;
	end
	
	methods
		function this = RegionName(parent, varargin)
			p = vt.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@vt.Component.TextBox(parent, varargin{:});
% 			this.setParameters('Enable', 'off');
			
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
			this.setParameters('String', state.currentRegion.name);
		end
		
		function [] = dispatchAction(this, ~, ~)
			newName = this.getParameter('String');
			this.action.dispatch(newName);
		end
	end
	
end