classdef FrameContainer < vt.StateListener
	properties
		frame
	end
	
	methods
		function this = FrameContainer(frame)
			p = inputParser;
			p.addRequired('frame', @(frame) isa(frame, 'vt.Frame'));
			parse(p, frame);
			
			this.frame = p.Results.frame;
		end
		
		function [] = triggerFrameUpdate(this, img)
			this.frame.update(img);
		end
		
		% State update methods
		function [] = updateCurrentFrameNo(this, state)
			this.showFrame(state.video, state.currentFrameNo);
		end
		
		function [] = updateVideo(this, state)
			this.showFrame(state.video, 1);
		end
		
		% Action methods %
		function [] = showFrame(this, video, frameNo)
			img = this.getFrame(video, frameNo);
			this.triggerFrameUpdate(img);
		end
		
		function [] = showMean(this, video)
			img = this.getMeanImaage(video);
			this.triggerFrameUpdate(img);
		end
		
		function [] = showStandardDeviationImage(this, video)
			img = this.getStandardDeviationImage(video);
			this.triggerFrameUpdate(img);
		end
		
		% Public helper methods %
		function frame = getFrame(~, video, frameNo)
			frame = reshape( ...
				video.matrix(frameNo,:), ...
				video.width, ...
				video.height ...
			);
		end
		
		function meanimage = getMeanImage(~, video)
			meanimage = reshape( ...
				mean(video.matrix, 1), ...
				video.width, ...
				video.height ...
			);
		end
		
		function stdimage = getStandardDeviationImage(~, video)
			stdimage = reshape( ...
				std(video.matrix, 1), ...
				video.width, ...
				video.height ...
			);
		end
	end
	
end

