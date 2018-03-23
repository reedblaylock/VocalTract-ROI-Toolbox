% The textbox that displays the height of the current rectangular region.
classdef Height < vt.Component.TextBox.RangeBox & vt.State.Listener
	properties
		currentRegion
		video
	end
	
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Adds this component to its parent, subclassing the RangeBox class 
		% (which accepts only numbers in a certain range).
		% Notable superclasses:
		% - vt.Component.TextBox.RangeBox
		% - vt.Action.Dispatcher (via RangeBox)
		% - vt.State.Listener
		function this = Height(parent, varargin)
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
		
		% Updates the String value of the textbox to the height value in State. 
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
			
			if ~isempty(this.currentRegion)
				this.setParameters('String', num2str(this.currentRegion.height));
				this.backupText = num2str(this.currentRegion.height);
			end
		end
		
		function [] = onVideoChange(this, state)
			this.video = state.video;
			this.maxValue = state.video.height;
		end
		
		function [] = dispatchAction(this, source, eventData)
			str = this.getParameter('String');
			num = str2double(str);
			validatedNum = this.validateData(num);
			if(~isempty(validatedNum))
				this.setParameters('String', num2str(validatedNum));
				this.backupText = num2str(validatedNum);
				action = this.actionFactory.actions.CHANGE_REGION_PARAMETER;
				action.prepare(this.region, 'height', validatedNum, this.video);
				action.dispatch();
			end
		end
	end
	
end