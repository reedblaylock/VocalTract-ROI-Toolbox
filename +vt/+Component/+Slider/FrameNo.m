classdef FrameNo < vt.Component.Slider & vt.Action.Dispatcher & vt.State.Listener
	properties
		actionType = @vt.Action.SetCurrentFrameNo
% 		listenerHandle
	end
	
	methods
		function this = FrameNo(parent)
			this@vt.Component.Slider(parent);
% 			this@vt.Action.Dispatcher();
			
			this.setCallback();
		end
		
		function [] = dispatchAction(this, ~, ~)
% 			frameNo = get(theSlider, 'Value');
			frameNo = this.getParameter('Value');
			frameNo = round(frameNo);
			this.action.dispatch(frameNo);
		end
		
		function [] = onVideoChange(this, state)
			this.setParameters( ...
				'Min', 1, ...
				'Max', state.video.nFrames, ...
				'Value', 1, ...
				'SliderStep', [1/state.video.nFrames, 10/state.video.nFrames] ...
			);
			switch(state.frameType)
				case 'frame'
					this.setParameters('Enable', 'on');
				case {'mean', 'std'}
					this.setParameters('Enable', 'off');
				otherwise
					% TODO: throw error?
			end
		end
		
		function [] = onCurrentFrameNoChange(this, state)
			frameNo = get(this.handle, 'Value');
			if(round(frameNo) ~= state.currentFrameNo)
% 				this.listenerHandle.Enabled = false;
				this.setParameters('Value', state.currentFrameNo);
% 				this.listenerHandle.Enabled = true;
			end
		end
		
		function [] = onFrameTypeChange(this, state)
			switch(state.frameType)
				case 'frame'
					this.setParameters('Enable', 'on');
				case {'mean', 'std dev'}
					this.setParameters('Enable', 'off');
				otherwise
					% TODO: throw error?
			end
		end
	end
		
	methods (Access = ?vt.Action.Dispatcher)
		function [] = setCallback(this, varargin)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Action.Dispatcher'));
			p.addOptional('callbackName', 'Callback', @ischar);
			p.parse(this, varargin{:});

			addlistener( ...
				this.handle, ...
				'Value', ...
				'PostSet', ...
				@(source, eventdata) dispatchAction(this, source.Name, eventdata.AffectedObject) ...
			);
		end
	end
	
end

