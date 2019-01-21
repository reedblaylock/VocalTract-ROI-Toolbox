classdef (Abstract) Listener < vt.Root
	methods
		function method = action2method(this, underscore_action)
			p = vt.InputParser;
			p.addRequired('underscore_action', @ischar);
			p.parse(underscore_action);
			
			method = this.underscore2camelCase(lower(p.Results.underscore_action));
		end
		
		function ccStr = underscore2camelCase(~, us_str)
			ccStr = regexprep(us_str, '_+(\w?)', '${upper($1)}');
		end
		
		function [] = register(this, action)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Listener'));
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
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Listener'));
			p.addRequired('methodName', @ischar);
			p.parse(this, methodName);
			
			methodList = methods(p.Results.this);
			b = ismember(p.Results.methodName, methodList);
		end
	end
	
end

