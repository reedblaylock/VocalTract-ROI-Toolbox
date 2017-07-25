classdef StateListener < vt.Listener
	properties
	end
	
	methods
		% For registering individual state listeners; this will probably be
		% replaced by registerStateListenerObject
		function [] = registerStateListener(this, state, propertyName)
			p = inputParser;
			p.addRequired('this',  @(this) isa(this, 'vt.StateListener'));
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
		
% 		function [] = registerStateListenerObject(this, state)
% 			p = inputParser;
% 			p.addRequired('this',  @(this) isa(this, 'vt.StateListener'));
% 			p.addRequired('state', @(state) isa(state, 'vt.State'));
% 			p.parse(this, state);
% 			
% 			m = methods(p.Results.this);
% 			
% 			for iMethod = 1:numel(m)
% 				method = m{iMethod};
% 				
% 			end
% 		end
		
		function [] = update(this, propertyName, state)
			p = inputParser;
			p.addRequired('this',  @(this) isa(this, 'vt.StateListener'));
			p.addRequired('propertyName', @ischar);
			p.addRequired('state', @(state) isa(state, 'vt.State'));
			parse(p, this, propertyName, state);
			
			method = this.property2method(propertyName);
			method(this, state);
		end
		
		function b = isCharOrCellStr(~, propertyName)
			b = (ischar(propertyName) || iscellstr(propertyName));
		end
	end
	
end

