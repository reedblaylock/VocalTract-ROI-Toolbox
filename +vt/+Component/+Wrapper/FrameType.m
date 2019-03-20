% This class is a wrapper for redux.Component.FrameType, providing the logic 
% required to make appropriate updates to the button group's visualization and
% to dispatch actions when buttons are selected.
classdef FrameType < redux.Component.Wrapper & redux.Action.Dispatcher & redux.State.Listener
	properties
		% An object of type redux.Component.FrameType
		frameType
	end
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Store a redux.Component.FrameType object, and register a callback
		% function (see redux.Component and redux.Action.Dispatcher).
		function this = FrameType(frameType)
			p = redux.InputParser;
			p.addRequired('frameType', @(frameType) isa(frameType, 'vt.Component.FrameType'));
			parse(p, frameType);
			
			this.frameType = p.Results.frameType;
			
			this.setCallback();
		end

		%%%%% STATE LISTENER %%%%%
		
		% Enable the frame type buttons. This function is called by
		% redux.State.Listener when the current video changes in State.
		function [] = onVideoChange(this, ~)
			set( this.frameType.buttons, 'Enable', 'on' );
		end
		
		%%%%% ACTION DISPATCHER %%%%%
		
		% Overwrite the redux.Action.Dispatcher function dispatchAction to include
		% the string of the clicked button, and to de-select other buttons.
		% http://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox
		% 18 September 2016
		function [] = dispatchAction( this, source, ~ ) 
			set( this.frameType.buttons(this.frameType.buttons==source), 'Value', 1 ); % select this
			set( this.frameType.buttons(this.frameType.buttons~=source), 'Value', 0 ) % unselect others
			
			buttonString = get( source, 'String' );
			action = this.actionFactory.actions.SET_FRAME_TYPE;
			action.prepare(buttonString);
			action.dispatch();
		end
	end
	
	%%%%% ACTION DISPATCHER %%%%%
	methods (Access = ?redux.Action.Dispatcher)
		% Overwrite the redux.Component function setCallback to use the frame
		% property's image handle (rather than the frame handle).
		function [] = setCallback(this, varargin)
			set( ...
				this.frameType.buttons, ...
				'Callback', ...
				@(source, eventdata) dispatchAction(this, source, eventdata) ...
			);
		end
	end
	
end

