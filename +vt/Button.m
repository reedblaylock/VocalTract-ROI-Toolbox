classdef Button < vt.Component
	properties
	end
	
	events
		DECREMENT
		INCREMENT
	end
	
	methods
		function this = Button(parent, label, action)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			p.addRequiredAction();
			p.parse(parent, label, action);
			
			this.handle = uicontrol(...
				'Parent', p.Results.parent.handle, ...
				'String', p.Results.label ...
			);
		
			this.setCallback( p.Results.action );
		end
	end
	
end

