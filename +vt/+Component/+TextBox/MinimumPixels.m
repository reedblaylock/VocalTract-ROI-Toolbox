% The textbox that displays the minimum pixel size of the current
% statistically-generated region.
classdef MinimumPixels < vt.Component.TextBox.RangeBox & vt.State.Listener
	properties
		% Required by Action.Dispatcher. When the user changes the value in this
		% textbox, send that value to State as the new minimum pixel value for
		% the current region.
		actionType = @vt.Action.ChangeMinimumPixels;
	end
	
	methods
		%%%%% CONSTRUCTOR %%%%%
		
		% Adds this component to its parent, subclassing the RangeBox class 
		% (which accepts only numbers in a certain range).
		% Notable superclasses:
		% - vt.Component.TextBox.RangeBox
		% - vt.Action.Dispatcher (via RangeBox)
		% - vt.State.Listener
		function this = MinimumPixels(parent, varargin)
			p = vt.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@vt.Component.TextBox.RangeBox(parent, varargin{:});
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
		
		% Updates the String value of the textbox to the minimum pixel value in
		% State. Called dynamically from State.Listener whenever the region
		% changes.
		function [] = onCurrentRegionChange(this, state)
			this.maxValue = min(state.video.height, state.video.width);
			this.setParameters('String', num2str(state.currentRegion.minimumPixels));
			this.data = num2str(state.currentRegion.minimumPixels);
		end
	end
	
end