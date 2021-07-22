classdef Export < redux.Action
	events
		EXPORT
	end
	
	properties
		regions
		video
	end
	
	methods
		function [] = prepare(this, regions, video)
			this.regions = regions;
			this.video = video;
		end
		
		function [] = dispatch(this)
			data = vt.Action.exportMview(this.regions, this.video);
            
            [~, basename, ~] = fileparts(this.video.filename);
            [file, path] = uiputfile([basename '_mview.mat']);
			
            if ~file
                % The user canceled. Do nothing.
                return
            end

            save(fullfile(path, file), 'data');
		end
	end
end