classdef RegionSettingsTab < redux.Component.Layout.VBox & redux.State.Listener
	
	properties
		gui
		styles
		regionParameterPanelIds
	end
	
	methods
		function this = RegionSettingsTab(parent, gui, styles)
			this@redux.Component.Layout.VBox( ...
				parent, ...
				'Padding', styles.Padding, ...
				'Spacing', styles.Spacing ...
			);
		
			this.gui = gui;
			this.regionParameterPanelIds = struct();
			this.styles = styles;
		end
		
		function gui = renderRegionConstants(this, parent, gui)
			gui.RegionConstants = redux.Component.Layout.Grid( ...
				parent, ...
				'Spacing', this.styles.Spacing + 2 ...
			);
		
			% 1-1 + Region name textbox
			gui.RegionNamePanel = redux.Component.Layout.Panel( ...
				gui.RegionConstants, ...
				'Title', 'Region name' ...
			);
			gui.RegionName = vt.Component.TextBox.RegionName( ...
				gui.RegionNamePanel ...
			);
		
			% 2-1 + Region Shape popup (drop-down) menu
			gui.RegionShapePanel = redux.Component.Layout.Panel( ...
				gui.RegionConstants, ...
				'Title', 'Region shape' ...
			);
			gui.RegionShapePopup = vt.Component.Popup.RegionShape( ...
				gui.RegionShapePanel ...
			);
		
			% 3-1 + Region Type popup (drop-down) menu
			gui.RegionTypePanel = redux.Component.Layout.Panel( ...
				gui.RegionConstants, ...
				'Title', 'Region type' ...
			);
			gui.RegionTypePopup = vt.Component.Popup.RegionType( ...
				gui.RegionTypePanel ...
			);
		
			% 4 + Empty placeholder
			gui.RegionConstantsPlaceholder = redux.Component.Layout.Empty( ...
				gui.RegionConstants ...
			);
		
			gui.RegionConstants.setParameters('Widths', [-1 -1], 'Heights', [-1 -1]);
		end
		
		function generateRegionParameterPanelId(this, shape)
			this.regionParameterPanelIds.(shape) = numel(fields(this.regionParameterPanelIds)) + 1;
		end
		
		function setRegionParameterPanel(this, shape)
			this.gui.RegionParameters.setParameters('Selection', this.regionParameterPanelIds.(shape));
		end
		
		function gui = renderCircleParameters(this, parent, gui)
			gui.RegionParameters_Circle = redux.Component.Layout.Grid( ...
				parent, ...
				'Spacing', this.styles.Spacing + 2 ...
			);
			
			% Radius
			gui.RegionRadiusPanel = redux.Component.Layout.Panel( ...
				gui.RegionParameters_Circle, ...
				'Title', 'Radius' ...
			);
			gui.RegionRadius = vt.Component.TextBox.Radius( ...
				gui.RegionRadiusPanel ...
			);
		
			% Change color button
			gui.RegionColor_Circle = vt.Component.Button.RegionColor( ...
				gui.RegionParameters_Circle, ...
				'Change color' ...
			);
		
			gui.RegionParameters_Circle.setParameters('Widths', [-1], 'Heights', [-1 -1]);
		
			this.generateRegionParameterPanelId('circle');
		end
		
		function gui = renderRectangleParameters(this, parent, gui)
			gui.RegionParameters_Rectangle = redux.Component.Layout.Grid( ...
				parent, ...
				'Spacing', this.styles.Spacing + 2 ...
			);
		
			% Width
			gui.RegionWidthPanel = redux.Component.Layout.Panel( ...
				gui.RegionParameters_Rectangle, ...
				'Title', 'Width' ...
			);
			gui.RegionWidth = vt.Component.TextBox.Width( ...
				gui.RegionWidthPanel ...
			);
		
			% Height
			gui.RegionHeightPanel = redux.Component.Layout.Panel( ...
				gui.RegionParameters_Rectangle, ...
				'Title', 'Height' ...
			);
			gui.RegionHeight = vt.Component.TextBox.Height( ...
				gui.RegionHeightPanel ...
			);
		
			% Change color button
			gui.RegionColor_Rectangle = vt.Component.Button.RegionColor( ...
				gui.RegionParameters_Rectangle, ...
				'Change color' ...
			);
		
			% + Timeseries display for centroid
			gui.TimeseriesDimensionPanel = redux.Component.Layout.Panel( ...
				gui.RegionParameters, ...
				'Title', 'Dimension' ...
			);
			gui.RegionShapePopup = vt.Component.Popup.TimeseriesDimension( ...
				gui.TimeseriesDimensionPanel ...
			);
		
			gui.RegionParameters_Rectangle.setParameters('Widths', [-1 -1], 'Heights', [-1 -1]);
		
			this.generateRegionParameterPanelId('rectangle');
		end
		
		function gui = renderStatisticalRegionParameters(this, parent, gui)
			gui.RegionParameters_Stat = redux.Component.Layout.Grid( ...
				parent, ...
				'Spacing', this.styles.Spacing + 2 ...
			);
		
			% Minimum # pixels textbox
			gui.RegionMinimumPixelsPanel = redux.Component.Layout.Panel( ...
				gui.RegionParameters_Stat, ...
				'Title', 'Minimum number of pixels' ...
			);
			gui.RegionMinimumPixels = vt.Component.TextBox.MinimumPixels( ...
				gui.RegionMinimumPixelsPanel ...
			);
			
			% Search radius textbox
			gui.RegionSearchRadiusPanel = redux.Component.Layout.Panel( ...
				gui.RegionParameters_Stat, ...
				'Title', 'Search radius' ...
			);
			gui.RegionSearchRadius = vt.Component.TextBox.SearchRadius( ...
				gui.RegionSearchRadiusPanel ...
			);
			
			% Tau textbox
			gui.RegionTauPanel = redux.Component.Layout.Panel( ...
				gui.RegionParameters_Stat, ...
				'Title', 'Tau' ...
			);
			gui.RegionTau = vt.Component.TextBox.Tau( ...
				gui.RegionTauPanel ...
			);
		
			gui.RegionParameters_Stat.setParameters('Widths', [-1 -1], 'Heights', [-1 -1]);
		
			this.generateRegionParameterPanelId('statistically_generated');
		end
		
		function gui = renderRegionParameters(this, parent, gui)
			gui.RegionParameters = redux.Component.Layout.CardPanel( ...
				parent ...
			);
			
			gui = this.renderStatisticalRegionParameters(gui.RegionParameters, gui);
			gui = this.renderRectangleParameters(gui.RegionParameters, gui);
			gui = this.renderCircleParameters(gui.RegionParameters, gui);
		end
		
		function gui = renderRegionDisplay(this, parent, gui)
			gui.RegionDisplay = redux.Component.Layout.Grid( ...
				parent, ...
				'Spacing', this.styles.Spacing + 2 ...
			);
		
			% Show origin checkbox
			gui.ShowOriginCheckbox = vt.Component.Checkbox.ShowOrigin( ...
				gui.RegionDisplay, ...
				'Show origin' ...
			);
		
			% Show outline checkbox
			gui.ShowOutlineCheckbox = vt.Component.Checkbox.ShowOutline( ...
				gui.RegionDisplay, ...
				'Show outline' ...
			);
		
			gui.RegionDisplay.setParameters('Widths', [-1 -1], 'Heights', [-1]);
		end
		
		function gui = renderRegionButtons(this, parent, gui)
			gui.RegionButtonsPanel = redux.Component.Layout.CardPanel( ...
				parent ...
			);
		
			% Panel view 2: Edit region mode
			gui.RegionButtonsView2 = redux.Component.Layout.Grid( ...
				gui.RegionButtonsPanel, ...
				'Spacing', this.styles.Spacing + 2 ...
			);
			gui.RegionButtonsEmpty1 = redux.Component.Layout.Empty( ...
				gui.RegionButtonsView2 ...
			);
			gui.DeleteRegionButton_Edit = vt.Component.Button.DeleteRegion( ...
				gui.RegionButtonsView2, ...
				'Delete region' ...
			);
			gui.StopEditingButton = vt.Component.Button.StopEditing( ...
				gui.RegionButtonsView2, ...
				'Stop editing' ...
			);
			gui.RegionButtonsView2.setParameters('Widths', [-1], 'Heights', [-1]);
			
			% Panel view 1
			gui.RegionButtonsView1 = redux.Component.Layout.Grid( ...
				gui.RegionButtonsPanel, ...
				'Spacing', this.styles.Spacing + 2 ...
			);
			gui.NewRegionButton = vt.Component.Button.NewRegion( ...
				gui.RegionButtonsView1, ...
				'New region' ...
			);
			gui.EditRegionButton = vt.Component.Button.EditRegion( ...
				gui.RegionButtonsView1, ...
				'Edit region' ...
			);
			gui.DeleteRegionButton_Default = vt.Component.Button.DeleteRegion( ...
				gui.RegionButtonsView1, ...
				'Delete region' ...
			);
			gui.RegionButtonsView1.setParameters('Widths', [-1], 'Heights', [-1]);
		end
		
		function gui = render(this, parent)
			gui = this.gui;
			
			gui = this.renderRegionConstants(parent, gui);
			gui = this.renderRegionParameters(parent, gui);
			gui = this.renderRegionDisplay(parent, gui);
			gui = this.renderRegionButtons(parent, gui);
		end
		
		function [] = redrawRegionEditingArea(this, state)
			curRegion = [];
			for iRegion = 1:numel(state.regions)
				if state.regions{iRegion}.id == state.currentRegion
					curRegion = state.regions{iRegion};
					break;
				end
			end
			
			shape = lower(strrep(curRegion.shape, '-', '_'));
			this.setRegionParameterPanel(shape);
		end
		
		%%% State.Listener functions
		function [] = onCurrentRegionChange(this, state)
			this.redrawRegionEditingArea(state);
		end
		
		function [] = onRegionsChange(this, state)
			% TODO: order display by (xcoordinate + ycoordinate) increasing
			
			this.redrawRegionEditingArea(state);
		end
		
		function [] = onIsEditingChange(this, state)
			switch (state.isEditing)
				case 'region'
					this.gui.RegionButtonsPanel.setParameters('Selection', 2);
				otherwise
					this.gui.RegionButtonsPanel.setParameters('Selection', 1);
			end
		end
	end
	
end
