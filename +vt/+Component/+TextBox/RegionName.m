% The textbox that displays the name of the current region region.
classdef RegionName < vt.Component.TextBox & vt.Action.Dispatcher & vt.State.Listener
	properties
		currentRegion
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
			this.currentRegion = [];
			
			regions = state.regions;
			for iRegion = 1:numel(regions)
				if regions{iRegion}.id == state.currentRegion
					this.currentRegion = regions{iRegion};
					break;
				end
			end
			
			this.setParameters('String', this.currentRegion.name);
		end
		
		% Overloads the Action.Dispatcher dispatchAction function. Sends the
		% current region name as a parameter when dispatching an action.
		function [] = dispatchAction(this, ~, ~)
			newName = this.getParameter('String');
			action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
			action.prepare(this.currentRegion, 'name', newName);
			action.dispatch();
		end
	end
	
end