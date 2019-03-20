classdef ExportFrame < redux.Action
	events
		EXPORT_FRAME
	end
	
	properties
		image
	end
	
	methods
		function [] = prepare(this, video, frameNo)
			p = inputParser;
			p.StructExpand = false;
			addRequired(p, 'video', @isstruct);
			addRequired(p, 'frameNo', @isnumeric);
			parse(p, video, frameNo);
			
			this.image = reshape( ...
				video.matrix(frameNo,:), ...
				video.width, ...
				video.height ...
			);
		
			this.image = this.image - min(this.image(:));
			this.image = this.image / max(this.image(:));
		end
		
		function [] = dispatch(this)
			loadType = 'jpg';
			[filename, pathname] = uiputfile(['*.' loadType], 'Save the current frame', 'frame');
			if isequal(filename,0) || isequal(pathname,0)
				return
			end
			fullpath = fullfile(pathname, filename);
			
			imwrite(this.image, fullpath);
		end
	end
end