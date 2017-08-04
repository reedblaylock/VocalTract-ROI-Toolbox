classdef FrameNo < vt.Component.TextBox.RangeBox & vt.State.Listener
	properties
		actionType = @vt.Action.SetCurrentFrameNo;
	end
	
	methods
		function this = FrameNo(parent, varargin)
			p = vt.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@vt.Component.TextBox.RangeBox(parent, varargin{:});
			
% 			this.setCallback();
		end
		
% 		function [] = dispatchAction(this, ~, ~)
% 			str = this.getParameter('String');
% 			num = str2double(str);
% 			try
% 				assert(~isempty(num) && ~isnan(num));
% % 				validatedNum = [];
% 				if(num < 1)
% 					validatedNum = 1;
% 				elseif(num > this.maxValue)
% 					validatedNum = this.maxValue;
% 				else
% 					validatedNum = num;
% 				end
% 				if(validatedNum ~= num)
% 					this.setParameters('String', num2str(validatedNum));
% 				end
% 				this.data = str;
% 				this.action.dispatch(validatedNum);
% 			catch
% 				this.setParameters('String', this.data);
% 				excp = MException('InvalidInput:FrameNo', 'Frame number must be numerical.');
% 				this.log.exception(excp);
% 			end
% 		end
		
		function [] = onCurrentFrameNoChange(this, state)
			str = num2str(state.currentFrameNo);
			this.data = str;
			this.setParameters('String', str);
		end
		
		function [] = onVideoChange(this, state)
			this.maxValue = state.video.nFrames;
			switch(state.frameType)
				case 'frame'
					this.setParameters('Enable', 'on');
				case {'mean', 'std'}
					this.setParameters('Enable', 'off');
				otherwise
					% TODO: throw error?
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
	
end