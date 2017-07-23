classdef MenuItem < vt.Component
	properties
	end
	
	events
		LOAD_AVI
		LOAD_VOCAL_TRACT
		CLOSE_GUI
		HELP
	end
	
	methods
		function this = MenuItem(parent, label, varargin)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			p.addOptionalAction();
			p.parse(parent, label, varargin{:});
			
			this.handle = uimenu( ...
				p.Results.parent.handle, ...
				'Label', p.Results.label ...
			);
			
			if(~isempty(p.Results.action))
				this.setCallback(p.Results.action);
			end
		end
	end
	
end

