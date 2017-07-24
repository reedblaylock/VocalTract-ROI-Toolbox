classdef Axes < vt.UpdatingComponent
	methods
		function this = Axes(parent)
			p = vt.InputParser;
			p.addParent();
			p.parse(parent);
			
			this.handle = axes('Parent', p.Results.parent.handle);
			
		end
		
		function [] = update(this, ~, currentFrame)
			plot(this.handle, 1:10, (1:10).^currentFrame);
		end
	end
	
end

