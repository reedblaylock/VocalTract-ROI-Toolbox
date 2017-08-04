classdef Height < vt.Component.TextBox & vt.State.Listener & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.ChangeRegionHeight;
		maxHeight
	end
	
	methods
		function this = Height(parent, varargin)
			p = vt.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@vt.Component.TextBox(parent, '', varargin{:});
% 			this.setParameters('String', '3');
% 			this.data = '3';
			
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
			this.maxHeight = state.video.height;
			this.setParameters('String', num2str(state.currentRegion.height));
			this.data = num2str(state.currentRegion.height);
		end
		
		function [] = dispatchAction(this, ~, ~)
			str = this.getParameter('String');
			num = str2double(str);
			try
				assert(~isempty(num) && ~isnan(num));
			catch
				this.setParameters('String', this.data);
				excp = MException('InvalidInput:RegionHeight', 'Height must be numerical.');
				this.log.exception(excp);
			end
			
% 			validatedNum = [];
			if(num < 1)
				validatedNum = 1;
			elseif(num > this.maxHeight)
				validatedNum = this.maxHeight;
			else
				validatedNum = num;
			end
			if(validatedNum ~= num)
				this.setParameters('String', num2str(validatedNum));
			end
			this.data = str;
			this.action.dispatch(validatedNum);
		end
	end
	
end