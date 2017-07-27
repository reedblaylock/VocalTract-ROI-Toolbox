classdef Listener < vt.Listener
	methods
% 		function this = Listener()
% 			this.registerAllMethodsToState();
% 		end
		
		% Right now, the propertyNames still have to be set expliclty in vt.Gui
% 		function [] = registerStateListener(this, state, propertyName)
% 			p = inputParser;
% 			p.addRequired('this',  @(this) isa(this, 'vt.State.Listener'));
% 			p.addRequired('state', @(state) isa(state, 'vt.State'));
% 			p.addRequired('propertyName', @(propertyName) isCharOrCellStr(this, propertyName));
% 			parse(p, this, state, propertyName);
% 			
% 			% eventdata.AffectedObject = the vt.State object
% 			addlistener( ...
% 				p.Results.state, ...
% 				p.Results.propertyName, ...
% 				'PostSet', ...
% 				@(source, eventdata) update(p.Results.this, source.Name, eventdata.AffectedObject) ...
% 			);
% 		end
		
		function [] = update(this, propertyName, state)
			p = inputParser;
			p.addRequired('this',  @(this) isa(this, 'vt.State.Listener'));
			p.addRequired('propertyName', @ischar);
			p.addRequired('state', @(state) isa(state, 'vt.State'));
			parse(p, this, propertyName, state);
			
			method = this.property2method(propertyName);
			try
				assert(this.isMethod(method));
				this.(method)(state);
			catch excp
				this.log.exception(excp);
			end
		end
		
		function b = isCharOrCellStr(~, propertyName)
			b = (ischar(propertyName) || iscellstr(propertyName));
		end
		
		function method = property2method(this, propertyName)
			p = inputParser;
			p.addRequired('propertyName', @ischar);
			p.parse(propertyName);
			
			circumfixed_propertyName = ['on_' p.Results.propertyName '_change'];
			method = this.underscore2camelCase(circumfixed_propertyName);
		end
		
		function [] = registerAllMethodsToState(this, state)
% 			stateGetter = vt.State.Getter;
% 			state = stateGetter.getState();
			propertyList = this.getProperties(state);
			
			addlistener( ...
				state, ...
				propertyList, ...
				'PostSet', ...
				@(source, eventdata) update(this, source.Name, eventdata.AffectedObject) ...
			);
		end
		
		function propertyList = getProperties(this, state)
			methodList = methods(this);
			propertyList = {};
			for iMethod = 1:numel(methodList)
				m = methodList{iMethod};
				p = this.method2property(m);
				if(~isempty(p) && this.isStateProperty(p, state))
					propertyList = [propertyList, p]; %#ok<AGROW>
				end
			end
		end
		
		function propertyName = method2property(~, method)
			propertyName = [];
			if(strcmp(method(1:2), 'on') && strcmp(method(end-5:end), 'Change'))
				propertyName = [lower(method(3)) method(4:end-6)];
			end
		end
		
		function tf = isStateProperty(~, propertyName, state)
			tf = ismember(propertyName, properties(state));
		end
		
	end
	
end

