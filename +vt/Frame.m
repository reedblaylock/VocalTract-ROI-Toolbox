classdef Frame < vt.Component
	methods
		function this = Frame(parent)
			p = vt.InputParser;
			p.addParent();
			p.parse(parent);
			
			this.handle = axes('Parent', p.Results.parent.handle);
			axis image;
		end
		
		function [] = update(this, frame)
			imagesc(frame, 'Parent', this.handle);
			axis image;
			colormap gray;
		end
	end
	
end

