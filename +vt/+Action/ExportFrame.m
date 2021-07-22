classdef ExportFrame < redux.Action
	events
		EXPORT_FRAME
	end
	
	properties
		videoname
		frameNo
		image
		path
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
			
			this.frameNo = frameNo;
			
			[this.path, this.videoname, ~] = fileparts(video.fullpath);
			this.videoname = strrep(this.videoname, '_withaudio', '');
		end
		
		function [] = dispatch(this)
			if ~exist(fullfile(this.path, this.videoname), 'dir')
				mkdir(fullfile(this.path, this.videoname));
			end
			currentdir = cd(fullfile(this.path, this.videoname));
			
			loadType = 'png';
			[filename, pathname] = uiputfile(['*.' loadType], 'Save the current frame', num2str(this.frameNo));
			cd(currentdir);
			if isequal(filename,0) || isequal(pathname,0)
				return
			end
			fullpath = fullfile(pathname, filename);
			
			imwrite(resize(this.image, 2, 'cubic'), fullpath);
% 			im = this.image;
% 			save('imtest.m', 'im');
		end
	end
end