% The textbox that displays the radius of the current circular region.
classdef Radius < redux.Component.TextBox.RangeBox & redux.State.Listener
	properties
		currentRegion
		video
	end
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Adds this component to its parent, subclassing the RangeBox class 
		% (which accepts only numbers in a certain range).
		% Notable superclasses:
		% - redux.Component.TextBox.RangeBox
		% - redux.Action.Dispatcher (via RangeBox)
		% - redux.State.Listener
		function this = Radius(parent, varargin)
			p = redux.InputParser();
			p.KeepUnmatched = true;
			p.addParent();
			p.parse(parent, varargin{:});
			
			this@redux.Component.TextBox.RangeBox(parent, varargin{:});
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
		
		% Updates the String value of the textbox to the radius value in State. 
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
			
			if isempty(this.currentRegion)
				this.setParameters('String', '');
				this.backupText = '';
			else
				this.setParameters('String', num2str(this.currentRegion.radius));
				this.backupText = num2str(this.currentRegion.radius);
			end
		end
		
		function [] = onVideoChange(this, state)
			this.maxValue = round(min(state.video.height, state.video.width) / 2);
			this.video = state.video;
		end
		
		function [] = onRegionsChange(this, state)
			for iRegion = 1:numel(state.regions)
				if state.regions{iRegion}.id == state.currentRegion
					this.currentRegion = state.regions{iRegion};
					break;
				end
			end
		end
		
		function [] = dispatchAction(this, ~, ~)
			str = this.getParameter('String');
			num = str2double(str);
			validatedNum = this.validateData(num);
			if(~isempty(validatedNum))
				this.setParameters('String', num2str(validatedNum));
				this.backupText = num2str(validatedNum);
				action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
				action.prepare(this.currentRegion, 'radius', validatedNum, this.video);
				action.dispatch();
			end
		end
	end
	
end