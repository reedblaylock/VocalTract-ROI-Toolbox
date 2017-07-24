classdef Frame < vt.UpdatingComponent
	methods
		function this = Frame(parent)
			p = vt.InputParser;
			p.addParent();
			p.parse(parent);
			
			this.handle = axes('Parent', p.Results.parent.handle);
			axis image;
		end
		
		% TODO:
		% Do you want to keep the whole matrix in the props? I think you have
		% to, since the update is coming from the state props change
		function [] = update(this, ~, currentFrameNo)
			currentFrame = reshape(obj.vidMatrix(currentFrameNo,:),obj.width,obj.height)
			imagesc(currentFrame);
		end
	end
	
end

