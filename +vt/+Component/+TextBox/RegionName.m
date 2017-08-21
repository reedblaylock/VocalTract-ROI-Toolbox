% The textbox that displays the name of the current region region.
classdef RegionName < vt.Component.TextBox & vt.Action.Dispatcher & vt.State.Listener
	properties
		% Required by Action.Dispatcher. When the user changes the value in this
		% textbox, send that value to State as the new name for the current
		% region.
		actionType = @vt.Action.ChangeRegionName;
	end
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Adds this component to its parent, subclassing the TextBox class.
		% Notable superclasses:
		% - vt.Component.TextBox
		% - vt.Action.Dispatcher
		% - vt.State.Listener
		function this = RegionName(parent, varargin)
			p = vt.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@vt.Component.TextBox(parent, varargin{:});
			
			this.setCallback();
		end
		
		%%%%% STATE LISTENER %%%%%
		
		% This textbox is enabled when a region is being edited, and disabled 
		% otherwise. Called dynamically from State.Listener when isEditing
		% changes.
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case 'region'
					this.setParameters('Enable', 'on');
				otherwise
					this.setParameters('Enable', 'off');
			end
		end
		
		% Updates the String value of the textbox to the region name in State. 
		% Called dynamically from State.Listener whenever the region changes.
		function [] = onCurrentRegionChange(this, state)
			this.setParameters('String', state.currentRegion.name);
		end
		
		% Overloads the Action.Dispatcher dispatchAction function. Sends the
		% current region name as a parameter when dispatching an action.
		function [] = dispatchAction(this, ~, ~)
			newName = this.getParameter('String');
			this.action.dispatch(newName);
		end
	end
	
end