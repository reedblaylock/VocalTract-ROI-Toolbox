classdef RegionColor < vt.Component.Button
	properties
		actionType = @vt.Action.ChangeRegionColor
	end
	
	methods
		function this = RegionColor(parent, label)
			this@vt.Component.Button(parent, label);
			
% 			this.setCallback();
		end
		
		function [] = dispatchAction(this, ~, ~)
			color = uisetcolor();
			if(~color)
				return;
			end
			
			this.action.dispatch(color);
		end
	end
	
end

