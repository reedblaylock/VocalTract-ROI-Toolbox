classdef FrameType < vt.Component.Layout.HButtonGroup & vt.Action.Dispatcher & vt.State.Listener
	methods
		function this = FrameType(parent, varargin)
			this@vt.Component.Layout.HButtonGroup(parent, varargin{:});
			
			this.setParameters('ButtonStyle', 'radio', 'Enable', 'off');
			this.handle.Buttons = {'frame', 'mean', 'std dev'};
			this.handle.SelectionChangeFcn = {@(source, event) dispatchAction(this, source, event)};
		end
		
		function [] = dispatchAction(this, source, ~)
			buttonName = source.SelectedObject.String;
			action = this.actionFactory.actions.SET_FRAME_TYPE;
			action.prepare(buttonName);
			action.dispatch();
		end
		
% 		function [] = onFrameTypeChange(this, state)
% 			this.setParameters('SelectedObject', state.frameType);
% 		end
		
		function [] = onVideoChange(this, state)
			this.setParameters('Enable', 'on');
		end
	end
	
end

