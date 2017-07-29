classdef FrameType < vt.Component.Layout.HButtonGroup & vt.Action.Dispatcher & vt.State.Listener
	properties
		actionType = @vt.Action.SetFrameType
	end
	
	methods
		function this = FrameType(parent, varargin)
			this@vt.Component.Layout.HButtonGroup(parent, varargin{:});
			
			this.setParameters('ButtonStyle', 'radio', 'Enable', 'off');
			this.handle.Buttons = {'frame', 'mean', 'std dev'};
			this.handle.SelectionChangeFcn = {@(source, event) changeButton(this, source, event)};
		end
		
		function [] = changeButton(this, source, ~)
			buttonName = source.SelectedObject.String;
			this.action.dispatch(buttonName);
		end
		
% 		function [] = onFrameTypeChange(this, state)
% 			this.setParameters('SelectedObject', state.frameType);
% 		end
		
		function [] = onVideoChange(this, state)
			this.setParameters('Enable', 'on');
		end
	end
	
end

