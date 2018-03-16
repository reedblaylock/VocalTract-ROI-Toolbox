% This is the slider that controls the current frame number shown.
classdef FrameNo < vt.Component.Slider & vt.Action.Dispatcher & vt.State.Listener
	properties
		maxFrame
	end
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Create a slider object, and set its callback (see
		% vt.Action.Dispatcher).
		function this = FrameNo(parent)
			this@vt.Component.Slider(parent);
			
			this.setCallback();
		end
		
		%%%%% STATE LISTENER %%%%%
		
		% Update the range and current value of this slider based on the length
		% of the new video. This function is called by State.Listener when the
		% video changes in State.
		function [] = onVideoChange(this, state)
			this.setParameters( ...
				'Min', 1, ...
				'Max', state.video.nFrames, ...
				'Value', 1, ...
				'SliderStep', [1/state.video.nFrames, 10/state.video.nFrames] ...
			);
			
			this.maxFrame = state.video.nFrames;
			this.switchFrameType(state.frameType);
		end
		
		% Update the current frame number of the slider. This function is called
		% by State.Listener when the current frame number changes in State.
		function [] = onCurrentFrameNoChange(this, state)
			frameNo = get(this.handle, 'Value');
			if(round(frameNo) ~= state.currentFrameNo)
				this.setParameters('Value', state.currentFrameNo);
			end
		end
		
		% Enable or disable the slider based on changes in frame type. This
		% function is called by State.Listener when the frame type changes in
		% State.
		function [] = onFrameTypeChange(this, state)
			this.switchFrameType(state.frameType);
		end
		
		%%%%% ACTION DISPATCHER %%%%%
		
		function [] = dispatchAction(this, ~, ~)
			frameNo = this.getParameter('Value');
			frameNo = round(frameNo);
			
			action = this.actionFactory.actions.SET_CURRENT_FRAME_NO;
			action.prepare(frameNo, this.maxFrame);
			this.action.dispatch();
		end
		
		%%%%% OTHER %%%%%
		
		% The slider is enabled when single frames are shown, and disabled
		% otherwise.
		function [] = switchFrameType(this, frameType)
			switch(frameType)
				case 'frame'
					this.setParameters('Enable', 'on');
				otherwise
					this.setParameters('Enable', 'off');
			end
		end
	end
		
	%%%%% ACTION DISPATCHER %%%%%
	methods (Access = ?vt.Action.Dispatcher)
		
		% Overwrite the vt.Component function setCallback. Dispatch an action
		% whenever the Value value of ths slider changes.
		function [] = setCallback(this, varargin)
			p = vt.InputParser;
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

