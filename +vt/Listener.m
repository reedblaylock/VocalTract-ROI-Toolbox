classdef (Abstract) Listener < vt.Root
	methods
		function method = action2method(~, underscoreAction)
			p = inputParser;
			p.addRequired('underscoreAction', @ischar);
			p.parse(underscoreAction);
			
			method = this.underscore2camelCase(this, lower(underscore_action));
		end
		
		function ccStr = underscore2camelCase(~, us_str)
			ccStr = regexprep(us_str, '_+(\w?)', '${upper($1)}');
		end
		
		function [] = register(this, action)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Action.Listener'));
			p.addRequired('action', @(action) isa(action, 'vt.Action'));
			p.parse(this, action);
			
			actionName = p.Results.action.getName();
			method = this.action2method(actionName);
			try
				assert(this.isMethod(method));
				addlistener( ...
					p.Results.action, ...
					actionName, ...
					@(source, eventdata) this.(method)(source, eventdata)...
				);
			catch excp
				this.log.exception(excp);
				% TODO: stop executing
			end
		end
		
		function b = isMethod(this, methodName)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Listener'));
			p.addRequired('methodName', @ischar);
			p.parse(this, methodName);
			
			methodList = methods(p.Results.this);
			b = ismember(methodName, methodList);
		end
	end
	
end

