% The textbox that displays the current frame number beneath the video frame.
classdef FrameNo < vt.Component.TextBox.RangeBox & vt.State.Listener
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Adds this component to its parent, subclassing the RangeBox class 
		% (which accepts only numbers in a certain range).
		% Notable superclasses:
		% - vt.Component.TextBox.RangeBox
		% - vt.Action.Dispatcher (via RangeBox)
		% - vt.State.Listener
		function this = FrameNo(parent, varargin)
			p = vt.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@vt.Component.TextBox.RangeBox(parent, varargin{:});
		end
		
		%%%%% STATE LISTENER %%%%%
		
		% Updates the String value of the textbox to the current frame number in
		% State. Called dynamically from State.Listener when the current frame
		% number changes.
		function [] = onCurrentFrameNoChange(this, state)
			str = num2str(state.currentFrameNo);
			this.backupText = str;
			this.setParameters('String', str);
		end
		
		% Disable or enable the checkbox when switching to a new video. Set the 
		% maxFrames property equal to the number of frames in the video. Called
		% dynamically from State.Listener when the current video changes.
		function [] = onVideoChange(this, state)
			this.maxValue = state.video.nFrames;
			this.switchFrameType(state.frameType);
		end
		
		% Disable or enable the checkbox when switching to a new frame type.
		% Called dynamically from State.Listener when the frame type changes.
		function [] = onFrameTypeChange(this, state)
			this.switchFrameType(state.frameType);
		end
		
		%%%%% OTHER %%%%%
		
		% Enable or disable the textbox depending on which frame type is
		% currently active.
		function [] = switchFrameType(this, frameType)
			switch(frameType)
				case 'frame'
					this.setParameters('Enable', 'on');
				otherwise
					this.setParameters('Enable', 'off');
			end
		end
		
		function [] = dispatchAction(this, source, eventData)
			str = this.getParameter('String');
			num = str2double(str);
			validatedNum = this.validateData(num);
			if(~isempty(validatedNum))
				this.setParameters('String', num2str(validatedNum));
				this.backupText = num2str(validatedNum);
				action = this.actionFactory.actions.SET_CURRENT_FRAME_NO;
				action.prepare(validatedNum, this.maxValue);
				action.dispatch();
			end
		end
	end
	
end