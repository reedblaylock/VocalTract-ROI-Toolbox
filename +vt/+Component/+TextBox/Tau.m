classdef Tau < vt.Component.TextBox.RangeBox %& vt.State.Listener
	properties
		actionType = @vt.Action.ChangeTau;
	end
	
	methods
		function this = Tau(parent, varargin)
			p = vt.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@vt.Component.TextBox.RangeBox(parent, varargin{:});
			
			this.minValue = 0.01;
			
% 			this.setCallback();
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
			this.maxValue = 1;
			this.setParameters('String', num2str(state.currentRegion.tau));
			this.data = num2str(state.currentRegion.tau);
		end
		
% 		function [] = dispatchAction(this, ~, ~)
% 			str = this.getParameter('String');
% 			num = str2double(str);
% 			try
% 				assert(~isempty(num) && ~isnan(num));
% 			catch
% 				this.setParameters('String', this.data);
% 				excp = MException('InvalidInput:RegionRadius', 'Radius must be numerical.');
% 				this.log.exception(excp);
% 			end
% 			
% % 			validatedNum = [];
% 			if(num <= 0)
% 				validatedNum = 0.1;
% 			elseif(num > this.maxValue)
% 				validatedNum = this.maxValue;
% 			else
% 				validatedNum = num;
% 			end
% 			if(validatedNum ~= num)
% 				this.setParameters('String', num2str(validatedNum));
% 			end
% 			this.data = str;
% 			this.action.dispatch(validatedNum);
% 		end
	end
	
end