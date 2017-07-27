classdef Listener < vt.Listener
	methods
		% Right now, the propertyNames still have to be set expliclty in vt.Gui
		function [] = registerStateListener(this, state, propertyName)
			p = inputParser;
			p.addRequired('this',  @(this) isa(this, 'vt.State.Listener'));
			p.addRequired('state', @(state) isa(state, 'vt.State'));
			p.addRequired('propertyName', @(propertyName) isCharOrCellStr(this, propertyName));
			parse(p, this, state, propertyName);
			
			% eventdata.AffectedObject = the vt.State object
			addlistener( ...
				p.Results.state, ...
				p.Results.propertyName, ...
				'PostSet', ...
				@(source, eventdata) update(p.Results.this, source.Name, eventdata.AffectedObject) ...
			);
		end
		
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
		
		function method = property2method(~, propertyName)
			p = inputParser;
			p.addRequired('propertyName', @ischar);
			p.parse(propertyName);
			
			circumfixed_propertyName = ['on_' p.Results.propertyName '_change'];
			method = this.underscore2camelCase(circumfixed_propertyName);
		end
	end
	
end

