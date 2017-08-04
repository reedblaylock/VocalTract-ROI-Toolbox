classdef (Abstract) RangeBox < vt.Component.TextBox & vt.Action.Dispatcher
	properties
		minValue = 1
		maxValue = 10
	end
	
	methods
		function this = RangeBox(parent, varargin)
			p = vt.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@vt.Component.TextBox(parent, varargin{:});
			
			this.setCallback();
		end
		
		function [] = dispatchAction(this, ~, ~)
			str = this.getParameter('String');
			num = str2double(str);
			validatedNum = this.validateData(num);
			if(~isempty(validatedNum))
				this.data = str;
				this.setParameters('String', num2str(validatedNum));
				this.action.dispatch(validatedNum);
			end
		end
		
		function validatedNum = validateData(this, num)
			p = inputParser;
			p.addRequired('num', @isnumeric);
			parse(p, num);
			
			num = p.Results.num;
			validatedNum = [];
			
			try
				assert(~isempty(num) && ~isnan(num));
			catch
				% The user entered something that isn't a number. You can't fix
				% this one, so return early.
				this.setParameters('String', this.data);
				excp = MException('InvalidInput:RangeBox:Non-numerical', 'Value must be numerical.');
				this.log.exception(excp);
				return;
			end
			
			try
				assert(num > this.minValue)
			catch
				% The user entered a value that was too low.
				validatedNum = this.minValue;
				excp = MException('InvalidInput:RangeBox:ExceedsMinValue', ['The minimum value for this field is ' num2str(this.minValue) '.']);
				this.log.exception(excp);
			end
			
			try
				assert(num < this.maxValue)
			catch
				% The user entered a value that was too high.
				validatedNum = this.maxValue;
				excp = MException('InvalidInput:RangeBox:ExceedsMaxValue', ['The maximum value for this field is ' num2str(this.maxValue) '.']);
				this.log.exception(excp);
			end
			
			if(isempty(validatedNum))
				validatedNum = num;
			end
		end
	end
	
end