classdef StateListener < handle
	properties
	end
	
	methods
		function [] = registerStateListener(this, state, propertyName)
			p = inputParser;
			p.addRequired('this',  @(this) isa(this, 'vt.StateListener'));
			p.addRequired('state', @(state) isa(state, 'vt.State'));
			p.addRequired('propertyName', @ischar);
			parse(p, this, state, propertyName);
			
			% update --> str2fcn(this.onStateChangeMethod) ?
			% eventdata.AffectedObject = the vt.State object
			addlistener( ...
				p.Results.state, ...
				p.Results.propertyName, ...
				'PostSet', ...
				@(source, eventdata) update(p.Results.this, source, eventdata.AffectedObject.(p.Results.propertyName)) ...
			);
		end
	end
	
end

