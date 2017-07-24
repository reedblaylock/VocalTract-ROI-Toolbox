classdef Axes < vt.Component
	
	properties
	end
	
	methods
		function this = Axes(parent)
			p = vt.InputParser;
			p.addParent();
			p.parse(parent);
			
			this.handle = axes('Parent', p.Results.parent.handle);
			
		end
		
		% this, source, eventdata
% 		function [] = redraw(this, ~, eventdata)
% 			c = eventdata.AffectedObject.currentFrame;
		function [] = redraw(this, ~, currentFrame)
			plot(this.handle, 1:10, (1:10).^currentFrame);
		end
	end
	
end

