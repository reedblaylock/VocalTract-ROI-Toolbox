classdef Frame < vt.Component.Wrapper & vt.State.Listener
	properties
		frame
	end
	
	methods
		function this = Frame(frame)
			p = inputParser;
			p.addRequired('frame', @(frame) isa(frame, 'vt.Component.Frame'));
			parse(p, frame);
			
			this.frame = p.Results.frame;
		end
		
		function [] = triggerFrameUpdate(this, img)
			this.frame.update(img);
		end
		
		% State update methods
		function [] = onCurrentFrameNoChange(this, state)
			switch(state.frameType)
				case 'frame'
					this.showFrame(state.video, state.currentFrameNo);
				case 'mean'
					this.showMeanImage(state.video);
				case 'std'
					this.showStandardDeviationImage(state.video);
				otherwise
					% TODO: throw error?
			end
		end
		
		function [] = onVideoChange(this, state)
			switch(state.frameType)
				case 'frame'
					this.showFrame(state.video, 1);
				case 'mean'
					this.showMeanImage(state.video);
				case 'std'
					this.showStandardDeviationImage(state.video);
				otherwise
					% TODO: throw error?
			end
		end
		
		function [] = onFrameTypeChange(this, state)
			switch(state.frameType)
				case 'frame'
					this.showFrame(state.video, state.currentFrameNo);
				case 'mean'
					this.showMeanImage(state.video);
				case 'std'
					this.showStandardDeviationImage(state.video);
				otherwise
					% TODO: throw error?
			end
		end
		
		function [] = onIsEditingChange(this, state)
			this.frame.isEditing = state.isEditing;
		end
		
		% Action methods %
		function [] = showFrame(this, video, frameNo)
			img = this.getFrame(video, frameNo);
			this.triggerFrameUpdate(img);
		end
		
		function [] = showMeanImage(this, video)
			img = this.getMeanImage(video);
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

