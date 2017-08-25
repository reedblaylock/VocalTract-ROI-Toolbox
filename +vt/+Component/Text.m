classdef Text < vt.Component
	properties
	end
	
	methods
		function this = Text(parent)
			p = vt.InputParser;
			p.addParent();
			p.parse(parent);
			
			this.handle = uicontrol( ...
				'Parent', p.Results.parent.handle, ...
				'Style', 'text' ...
			);
		
			addlistener(this.handle, 'ObjectBeingDestroyed', @(s, e) showDeletion(this, s, e));
		end
		
		function [] = showDeletion(this, s, e)
			disp('NotificationBar handle is being deleted');
		end
	end
	
end

