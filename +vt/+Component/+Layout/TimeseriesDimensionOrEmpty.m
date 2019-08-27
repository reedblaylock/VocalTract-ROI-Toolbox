classdef TimeseriesDimensionOrEmpty < redux.Component.Layout.CardPanel & redux.State.Listener
	
	properties
		gui
		styles
		targetComponentName
	end
	
	methods
		function this = TimeseriesDimensionOrEmpty(parent, styles)
			this@redux.Component.Layout.CardPanel( ...
				parent ...
			);
			
			this.styles = styles;
			this.targetComponentName = 'TimeseriesDimensionPanelOrEmpty';
		end
		
		function gui = render(this, gui)
			% + Timeseries display for centroid
			gui.(this.targetComponentName) = redux.Component.Layout.CardPanel( ...
				this ...
			);
		
			% TimeseriesDimension popup
			gui.TimeseriesDimensionPanel = redux.Component.Layout.Panel( ...
				gui.(this.targetComponentName), ...
				'Title', 'Dimension' ...
			);
			gui.TimeseriesDimensionPopup = vt.Component.Popup.TimeseriesDimension( ...
				gui.TimeseriesDimensionPanel ...
			);
		
			% Empty panel
			gui.TimeseriesDimensionEmpty = redux.Component.Layout.Empty( ...
				gui.(this.targetComponentName) ...
			);
			
			this.gui = gui;
		end
		
		%%% State.Listener methods
		function [] = onRegionsChange(this, state)
			curRegion = [];
			for iRegion = 1:numel(state.regions)
				if state.regions{iRegion}.id == state.currentRegion
					curRegion = state.regions{iRegion};
					break;
				end
			end
			
			type = '';
			if ~isempty(curRegion)
				type = lower(strrep(curRegion.type, '-', '_'));
			end
			
			switch (type)
				case 'centroid'
					this.gui.(this.targetComponentName).setParameters('Selection', 1);
				otherwise
					this.gui.(this.targetComponentName).setParameters('Selection', 2);
			end
		end
		
		function [] = onCurrentRegionChange(this, state)
			curRegion = [];
			for iRegion = 1:numel(state.regions)
				if state.regions{iRegion}.id == state.currentRegion
					curRegion = state.regions{iRegion};
					break;
				end
			end
			
			type = '';
			if ~isempty(curRegion)
				type = lower(strrep(curRegion.type, '-', '_'));
			end
			
			switch (type)
				case 'centroid'
					this.gui.(this.targetComponentName).setParameters('Selection', 1);
				otherwise
					this.gui.(this.targetComponentName).setParameters('Selection', 2);
			end
		end
	end
	
end

