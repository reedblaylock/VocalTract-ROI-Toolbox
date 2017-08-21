% The textbox that displays the tau value of the current statistically-generated
% region.
classdef Tau < vt.Component.TextBox.RangeBox & vt.State.Listener
	properties
		% Required by Action.Dispatcher. When the user changes the value in this
		% textbox, send that value to State as the new tau for the current
		% region.
		actionType = @vt.Action.ChangeTau;
	end
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Adds this component to its parent, subclassing the RangeBox class 
		% (which accepts only numbers in a certain range). The minimum value for
		% this range is hard-coded as 0.01.
		% Notable superclasses:
		% - vt.Component.TextBox.RangeBox
		% - vt.Action.Dispatcher (via RangeBox)
		% - vt.State.Listener
		function this = Tau(parent, varargin)
			p = vt.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@vt.Component.TextBox.RangeBox(parent, varargin{:});
			
			this.minValue = 0.01;
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
		
		% Updates the String value of the textbox to the tau in State. Called 
		% dynamically from State.Listener whenever the region changes.
		function [] = onCurrentRegionChange(this, state)
			this.maxValue = 1;
			this.setParameters('String', num2str(state.currentRegion.tau));
			this.data = num2str(state.currentRegion.tau);
		end
	end
	
end