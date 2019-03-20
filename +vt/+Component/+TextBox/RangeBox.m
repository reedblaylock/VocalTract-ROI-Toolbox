% An abstract class, inherited by textboxes that enforce their values to fit a
% numerical range.
classdef (Abstract) RangeBox < redux.Component.TextBox & redux.Action.Dispatcher
	properties
		% Specify a default min and max value. These are usually over-written by
		% child classes.
		minValue = 1
		maxValue = 10
		
		% Child classes must specify an actionType (see Action.Dispatcher).
	end
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Adds this component to its parent, subclassing the TextBox class. Set
		% the callback function for dispatching an action.
		% Notable superclasses:
		% - redux.Component.TextBox
		% - redux.Action.Dispatcher
		% - redux.State.Listener
		function this = RangeBox(parent, varargin)
			p = redux.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@redux.Component.TextBox(parent, varargin{:});
			
			this.setCallback();
		end
		
		% Convert the current String value to a number. If it is within the
		% appropriate range, dispatch an action.
		function [] = dispatchAction(this, ~, ~)
			str = this.getParameter('String');
			num = str2double(str);
			validatedNum = this.validateData(num);
			if(~isempty(validatedNum))
				this.backupText = num2str(validatedNum);
				this.setParameters('String', num2str(validatedNum));
				this.action.dispatch(validatedNum);
			end
		end
		
		% Make sure that the current value is within the specified range.
		function validatedNum = validateData(this, num)
			p = redux.InputParser;
			p.addRequired('num', @isnumeric);
			parse(p, num);
			
			num = p.Results.num;
			validatedNum = [];
			
			try
				assert(~isempty(num) && ~isnan(num));
			catch
				% The user entered something that isn't a number. You can't fix
				% this one, so return early.
				this.setParameters('String', this.backupText);
				excp = MException('InvalidInput:RangeBox:Non-numerical', 'Value must be numerical.');
				this.log.exception(excp);
				return;
			end
			
			try
				assert(num >= this.minValue)
			catch
				% The user entered a value that was too low.
				validatedNum = this.minValue;
				excp = MException('InvalidInput:RangeBox:ExceedsMinValue', ['The minimum value for this field is ' num2str(this.minValue) '.']);
				this.log.exception(excp);
			end
			
			try
				assert(num <= this.maxValue)
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