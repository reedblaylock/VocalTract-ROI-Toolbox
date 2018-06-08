% This class is initialized in runGui.m. The constructor function creates a Log
% object and initializes it; the run function creates a set of pseudo-global
% objects, creates the GUI components, sets up the connections between the GUI
% components and their functionality, and disables most interface capabilities
% until a video is loaded.
classdef App < vt.Root & vt.State.Listener
	properties
		state
		styles
		reducer
		gui
		actionFactory
		
		% TODO: get this from user-specified preferences
		currentRegion = struct('shape', 'Circle')
	end
	
	methods
		function this = App(debugSetting)
			p = inputParser;
			addOptional(p, 'debugSetting', 0);
			parse(p, debugSetting);
			
			this.log = vt.Log(p.Results.debugSetting);
			this.log.on();
		end
		
		function [] = run(this)
			this.state = vt.State();
			this.reducer = vt.Reducer(this.state);
			this.actionFactory = vt.Action.Factory(this.reducer);
			
			this.styles = this.createStyles();
			this.gui = this.createInterface();
			
			this.initializeListeners();
			
			set(findall(this.gui.Window.handle, 'Type', 'uicontrol'), 'Enable', 'off');
			set(this.gui.NotificationBar.handle, 'Enable', 'on');
		end
		
		function [] = initializeListeners(this)
			% Initialize all the gui elements with a log, register their state
			% listeners, and get them registered with the action listener
			fields = fieldnames(this.gui);
			for iField = 1:numel(fields)
				obj = this.gui.(fields{iField});
				if(isa(obj, 'vt.Root'))
					obj.log = this.log;
				end
				if(isa(obj, 'vt.State.Listener'))
					obj.registerAllMethodsToState(this.state);
				end
				if(isa(obj, 'vt.Action.Dispatcher'))
					obj.actionFactory = this.actionFactory;
				end
			end
			
			% Give all the properties of this vt.Gui a log as well
			propertyList = properties(this);
			for iProp = 1:numel(properties(this))
				prop = propertyList{iProp};
				if(isa(this.(prop), 'vt.Root'))
					this.(prop).log = this.log;
				end
				if(isa(this.(prop), 'vt.Action.Factory'))
					actionNames = fieldnames(this.(prop).actions);
					for iAction = 1:numel(actionNames)
						this.(prop).actions.(actionNames{iAction}).log = this.log;
					end
				end
			end
			
			% Register vt.App as a state listener
			this.registerAllMethodsToState(this.state);
		end
		
		function [] = initializeComponent(this, obj)
			if(isa(obj, 'vt.Root'))
				obj.log = this.log;
			end
			if(isa(obj, 'vt.State.Listener'))
				obj.registerAllMethodsToState(this.state);
			end
			if(isa(obj, 'vt.Action.Dispatcher'))
				obj.actionFactory = this.actionFactory;
			end
		end
		
		function styles = createStyles(~)
			styles = struct( ...
				'Padding', 3, ...
				'Spacing', 3 ...
			);
		end
		
		% Create the GUI.
		function gui = createInterface(this)
			% Create the user interface for the application and return a
			% structure of handles for global use.
			gui = struct();
			
			% Open a window
			gui.Window = vt.Component.Window( 'VocalTract ROI Toolbox' );
			
			% + Menu
			gui = this.addMenu(gui);
			
			% Arrange the main interface
			gui.MainLayoutWrapper = vt.Component.Layout.VBoxFlex( ...
				gui.Window, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.MainLayout = vt.Component.Layout.HBoxFlex( ...
				gui.MainLayoutWrapper, ...
				'Spacing', this.styles.Spacing ...
			);
			
			% + Notification bar
			gui = this.addNotificationBar(gui);
			
			% Set the relative sizing between the notification bar and the rest
			% of the interface
			gui.MainLayoutWrapper.setParameters('Heights', [-15, -1]);
			
			% + Image
			gui.LeftBox = vt.Component.Layout.VBox( ...
				gui.MainLayout, ...
				'Padding', this.styles.Padding, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.LeftBoxImageContainer = vt.Component.Container( ...
				gui.LeftBox ...
			);
			
			% + Image controls
			gui = this.addImageControls(gui);
			
			% + Right panels
			gui.RightBox = vt.Component.Layout.TabPanel( ...
				gui.MainLayout, ...
				'TabWidth', 100, ...
				'Padding', this.styles.Padding ...
			);
			% TODO: this box might be superfluous
			gui.RegionSettingsTab = vt.Component.Layout.HBox( ...
				gui.RightBox, ...
				'Padding', this.styles.Padding, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.TimeSeriesTab = vt.Component.Layout.VBox( ...
				gui.RightBox, ...
				'Padding', this.styles.Padding, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.RightBox.setParameters('TabTitles', {'Region settings', 'Timeseries'});
			
			%%% Region settings panel
			gui = this.addRegionSettingsGrid(gui);
            
            % Make sure regionsettings tab is the currently open one
            gui.RightBox.setParameters('Selection', 1);
		end
		
		function [] = deleteAllTimeseries(this, ~)
			nDeletions = numel(this.gui.TimeSeriesTab.handle.Contents);
			% delete by id
			for iDeletion = 1:nDeletions
				child = this.gui.TimeSeriesTab.handle.Contents(iDeletion);
				label = ['Timeseries' num2str(get(child, 'Tag'))];
				containerLabel = [label 'Container'];
				this.guiDelete(containerLabel);
				this.guiDelete(label);
			end
			delete(this.gui.TimeSeriesTab.handle.Contents(:));
		end
		
		function [] = redrawAllTimeseries(this, state)
			if isempty(state.regions) || ~numel(state.regions)
				% There are no regions to draw
				return;
			end
			
			for iRegion = 1:numel(state.regions)
				region = state.regions{iRegion};
				if ~isempty(region.timeseries)
					label = ['Timeseries' num2str(region.id)];
					containerLabel = [label 'Container'];

					this.gui.(containerLabel) = vt.Component.Container( ...
						this.gui.TimeSeriesTab, ...
						'Tag', num2str(region.id) ...
					);
					this.gui.(label) = vt.Component.Timeseries( ...
						this.gui.(containerLabel), ...
						region.timeseries, ...
						region.color, ...
						state.currentFrameNo, ...
						'Title', region.name, ...
						'Tag', num2str(region.id) ...
					);
					this.initializeComponent(this.gui.(containerLabel));
					this.initializeComponent(this.gui.(label));
				end
			end
		end
		
		function [] = onRegionsChange(this, state)
			% You should probably show currentRegion's timeseries too. Maybe you
			% can color the back panel differently to indicate that it's
			% temporary, somehow?
			
			% TODO: order display by (xcoordinate + ycoordinate) increasing
			
			this.deleteAllTimeseries(state);
			this.redrawAllTimeseries(state);
			
			this.redrawRegionEditingArea(state);
		end
		
		function [] = guiDelete(this, fieldname)
			delete(this.gui.(fieldname));
			this.gui.(fieldname) = [];
			this.gui = rmfield(this.gui, fieldname);
		end
		
		function gui = addMenu(~, gui)
			% + File menu
			gui.FileMenu = vt.Component.MenuItem( gui.Window,   'File' );
			gui.LoadMenu = vt.Component.MenuItem( gui.FileMenu, 'Load...' );
			gui.LoadAvi  = vt.Component.MenuItem.Load( gui.LoadMenu, 'AVI', 'avi' );
			
			gui.Export   = vt.Component.MenuItem.Export( gui.FileMenu, 'Export timeseries' );
			
% 			gui.ExitMenu = vt.Component.MenuItem.Exit( gui.FileMenu, 'Exit' );

			% + Help menu
			gui.HelpMenu = vt.Component.MenuItem( gui.Window, 'Help' );
			gui.DocumentationMenu = vt.Component.MenuItem.Help( gui.HelpMenu, 'Documentation' );
		end
		
		function gui = addNotificationBar(~, gui)
			gui.NotificationBar = vt.Component.Text.NotificationBar( ...
				gui.MainLayoutWrapper ...
			);
			gui.NotificationBarWrapper = vt.Component.Wrapper.NotificationBar( ...
				gui.NotificationBar ...
			);
		end
		
		function gui = addImageControls(this, gui)
			gui.LeftBoxFrameControls = vt.Component.Layout.VBox( ...
				gui.LeftBox ...
			);
			gui.LeftBoxFrameNoControls  = vt.Component.Layout.HBox( ...
				gui.LeftBoxFrameControls ...
				);
			gui.SetCurrentFrameNoControl = vt.Component.TextBox.FrameNo( ...
				gui.LeftBoxFrameNoControls ...
			);
			gui.Slider = vt.Component.Slider.FrameNo( ...
				gui.LeftBoxFrameNoControls ...
			);
% 			gui.FrameTypeControls = vt.Component.ButtonGroup.FrameType( ...
% 				gui.LeftBoxFrameControls ...
% 			);
% 			gui.FrameTypeControls = vt.Component.FrameType( ...
% 				gui.LeftBoxFrameControls ...
% 			);
			gui.FrameTypeButtonBox = vt.Component.Layout.HButtonBox( ...
				gui.LeftBoxFrameControls, ...
				'Padding', 5, ...
				'HorizontalAlignment', 'center' ...
			);
% 			'ButtonSize', [200 20], ... 
			gui.FrameTypeButtons = vt.Component.FrameType( ...
				gui.FrameTypeButtonBox ...
			);
			gui.frameTypeButtonsContainer = vt.Component.Wrapper.FrameType( ...
				gui.FrameTypeButtons ...
			);

			% Can this be done when you're creating the object?
			gui.LeftBox.setParameters( 'Heights', [-1, 50], 'Padding', this.styles.Padding );

			gui.Frame = vt.Component.Frame( gui.LeftBoxImageContainer );
			gui.frameContainer = vt.Component.Wrapper.Frame( gui.Frame );
		end
		
		function gui = addRegionSettingsGrid(this, gui)
			gui.RightBoxGrid = vt.Component.Layout.Grid( ...
				gui.RegionSettingsTab, ...
				'Spacing', this.styles.Spacing + 2 ...
			);
			% 1-1 + Region name textbox
			gui.RegionNamePanel = vt.Component.Layout.Panel( ...
				gui.RightBoxGrid, ...
				'Title', 'Region name' ...
			);
			gui.RegionName = vt.Component.TextBox.RegionName( ...
				gui.RegionNamePanel ...
			);
			% 2-1 + Region Shape popup (drop-down) menu
			gui.RegionShapePanel = vt.Component.Layout.Panel( ...
				gui.RightBoxGrid, ...
				'Title', 'Region shape' ...
			);
			gui.RegionShapePopup = vt.Component.Popup.RegionShape( ...
				gui.RegionShapePanel ...
			);
			% 3-1 + Region Type popup (drop-down) menu
			gui.RegionTypePanel = vt.Component.Layout.Panel( ...
				gui.RightBoxGrid, ...
				'Title', 'Region type' ...
			);
			gui.RegionTypePopup = vt.Component.Popup.RegionType( ...
				gui.RegionTypePanel ...
			);
			% 4-1 + Snap to midline checkbox
			gui.SnapToMidlineCheckbox = vt.Component.Checkbox.SnapToMidline( ...
				gui.RightBoxGrid, ...
				'Snap to midline' ...
			);
			% 5-1 + Empty area (for spacing purposes)
			gui.Empty5 = vt.Component.Layout.Empty( ...
				gui.RightBoxGrid ...
			);
			% 6-1 + Change color button
			gui.ChangeColorButton = vt.Component.Button.RegionColor( ...
				gui.RightBoxGrid, ...
				'Change color' ...
			);
			% 7-1 + Show origin checkbox
			gui.ShowOriginCheckbox = vt.Component.Checkbox.ShowOrigin( ...
				gui.RightBoxGrid, ...
				'Show origin' ...
			);
			% 8-1 + Show outline checkbox
			gui.ShowOutlineCheckbox = vt.Component.Checkbox.ShowOutline( ...
				gui.RightBoxGrid, ...
				'Show outline' ...
			);
			% 9-1 + Show fill checkbox
			gui.ShowFillCheckbox = vt.Component.Checkbox.ShowFill( ...
				gui.RightBoxGrid, ...
				'Show fill' ...
			);
			% 1-2 + Radius and Width
			gui.RegionSettings1_2 = vt.Component.Layout.Panel( ...
				gui.RightBoxGrid, ...
				'Title', 'Radius' ...
			);
			% Selection 1
			gui.RegionWidth = vt.Component.TextBox.Width( ...
				gui.RegionSettings1_2 ...
			);
			% Selection 2
			gui.RegionRadius = vt.Component.TextBox.Radius( ...
				gui.RegionSettings1_2 ...
			);
			% 2-2 + Empty space and Height
			gui.RegionSettings2_2 = vt.Component.Layout.Panel( ...
				gui.RightBoxGrid ...
			);
			% Selection 1
			gui.RegionHeight = vt.Component.TextBox.Height( ...
				gui.RegionSettings2_2 ...
			);
			% Selection 2
			gui.RegionSettingsEmpty2_2 = vt.Component.Layout.Empty( ...
				gui.RegionSettings2_2 ...
			);
			% 3-2 + Empty space
			gui.RegionSettings3_2 = vt.Component.Layout.Empty( ...
				gui.RightBoxGrid ...
			);
			% 4-2 + Allow multiple origins checkbox
			gui.MultipleOriginsCheckbox = vt.Component.Checkbox.MultipleOrigins( ...
				gui.RightBoxGrid, ...
				'Allow multiple origins' ...
			);
			% 5-2 + Empty area (for spacing purposes)
			gui.RegionSettings5_2 = vt.Component.Layout.Empty( ...
				gui.RightBoxGrid ...
			);
			% 6-2 + Empty area
			gui.RegionSettings6_2 = vt.Component.Layout.Empty( ...
				gui.RightBoxGrid ...
			);
			% 7-2 + New region
			gui.RegionSettings7_2 = vt.Component.Layout.CardPanel( ...
				gui.RightBoxGrid ...
			);
			% Selection 1
			gui.EmptyPanel7_2 = vt.Component.Layout.Empty( ...
				gui.RegionSettings7_2 ...
			);
			% Selection 2
			gui.NewRegionButton = vt.Component.Button.NewRegion( ...
				gui.RegionSettings7_2, ...
				'New region' ...
			);
			% 8-2 + Edit region
			gui.RegionSettings8_2 = vt.Component.Layout.CardPanel( ...
				gui.RightBoxGrid ...
			);
			% Selection 1
			gui.DeleteRegionButton_Edit = vt.Component.Button.DeleteRegion( ...
				gui.RegionSettings8_2, ...
				'Delete region' ...
			);
			% Selection 2
			gui.EditRegionButton = vt.Component.Button.EditRegion( ...
				gui.RegionSettings8_2, ...
				'Edit region' ...
			);
			% 9-2 + Delete region
			gui.RegionSettings9_2 = vt.Component.Layout.CardPanel( ...
				gui.RightBoxGrid ...
			);
			% Selection 1
			gui.StopEditingButton = vt.Component.Button.StopEditing( ...
				gui.RegionSettings9_2, ...
				'Stop editing' ...
			);
			% Selection 2
			gui.DeleteRegionButton_Default = vt.Component.Button.DeleteRegion( ...
				gui.RegionSettings9_2, ...
				'Delete region' ...
			);
			
			gui.RightBoxGrid.setParameters('Widths', [-1 -1], 'Heights', -1.*ones(1, 9));
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case 'region'
					% 7-2 + Empty panel (replace New Region button)
					this.gui.RegionSettings7_2.setParameters('Selection', 1);
					% 8-2 + Delete Region button (replace Edit Region button)
					this.gui.RegionSettings8_2.setParameters('Selection', 1);
					% 9-2 + Stop Editing button (replace Delete Region button)
					this.gui.RegionSettings9_2.setParameters('Selection', 1);
				otherwise
					% Not editing anything
					% 7-2 + New Region button (replaces empty panel)
					this.gui.RegionSettings7_2.setParameters('Selection', 2);
					% 8-2 + Edit Region button (replace Delete Region button)
					this.gui.RegionSettings8_2.setParameters('Selection', 2);
					% 9-2 + Delete Region button (replace Stop Editing button)
					this.gui.RegionSettings9_2.setParameters('Selection', 2);
			end
		end
		
		function [] = redrawRegionEditingArea(this, state)
			% REDRAW REGION EDITING AREA
			% Prevent re-drawing when other changes than shape changes are made
			currentRegion = [];
			for iRegion = 1:numel(state.regions)
				if state.regions{iRegion}.id == state.currentRegion
					currentRegion = state.regions{iRegion};
					break;
				end
			end
			if isempty(currentRegion) || strcmp(this.currentRegion.shape, currentRegion.shape)
				return;
			end
			
			% TODO: If isEditing='region', 'Enable'='on'; otherwise,
			% 'Enable'='off'
			switch(currentRegion.shape)
				case 'Circle'
					% 1-2 + Radius
					this.gui.RegionSettings1_2.setParameters( ...
						'Title', 'Radius', ...
						'Selection', 2 ...
					);
% 					this.gui.RegionSettings1_2.setParameters('Selection', 2);
					% 2-2 + Empty space
					this.gui.RegionSettings2_2.setParameters( ...
						'Title', '', ...
						'Selection', 2 ...
					);
% 					this.gui.RegionSettings2_2.setParameters('Title', '');
					% 3-2 + Empty space
% 					this.gui.RegionSettings3_2.setParameters('Selection', 2);
				case 'Rectangle'
					% 1-2 + Width
					this.gui.RegionSettings1_2.setParameters( ...
						'Title', 'Width', ...
						'Selection', 1 ...
					);
% 					this.gui.RegionSettings1_2.setParameters('Selection', 1);
					% 2-2 + Height
					this.gui.RegionSettings2_2.setParameters( ...
						'Title', 'Height', ...
						'Selection', 1 ...
					);
% 					this.gui.RegionSettings2_2.setParameters('Selection', 1);
					% 3-2 + Empty space
% 					this.gui.RegionSettings3_2.setParameters('Selection', 1);
				case 'Statistically-generated'
					% TODO: Use the panel Selection property instead
					% 1-2 + Minimum # pixels textbox
					this.gui.RegionSettings1_2 = vt.Component.Layout.Panel( ...
						this.gui.RightBoxGrid, ...
						'Title', 'Minimum number of pixels' ...
					);
					this.gui.MinimumPixels = vt.Component.TextBox.MinimumPixels( ...
						this.gui.RegionSettings1_2, ...
						'String', num2str(currentRegion.minimumPixels) ...
					);
					if(~strcmp(state.isEditing, 'region'))
						this.gui.MinimumPixels.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings1_2);
					this.initializeComponent(this.gui.MinimumPixels);
					% TODO: this is a hack
					this.gui.MinimumPixels.currentRegion = currentRegion;
					this.gui.MinimumPixels.video = state.video;
					% 2-2 + Search radius textbox
					this.gui.RegionSettings2_2 = vt.Component.Layout.Panel( ...
						this.gui.RightBoxGrid, ...
						'Title', 'Search radius' ...
					);
					this.gui.SearchRadius = vt.Component.TextBox.SearchRadius( ...
						this.gui.RegionSettings2_2, ...
						'String', num2str(currentRegion.searchRadius) ...
					);
					if(~strcmp(state.isEditing, 'region'))
						this.gui.SearchRadius.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings2_2);
					this.initializeComponent(this.gui.SearchRadius);
					% TODO: this is a hack
					this.gui.SearchRadius.currentRegion = currentRegion;
					this.gui.SearchRadius.video = state.video;
					% 3-2 + Tau textbox
					this.gui.RegionSettings3_2 = vt.Component.Layout.Panel( ...
						this.gui.RightBoxGrid, ...
						'Title', 'Tau' ...
					);
					this.gui.Tau = vt.Component.TextBox.Tau( ...
						this.gui.RegionSettings3_2, ...
						'String', num2str(currentRegion.tau) ...
					);
					if(~strcmp(state.isEditing, 'region'))
						this.gui.Tau.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings3_2);
					this.initializeComponent(this.gui.Tau);
					% TODO: this is a hack
					this.gui.Tau.currentRegion = currentRegion;
					this.gui.Tau.video = state.video;
				otherwise
					% TODO: add the rest
			end
			
			% re-order the elements so that elements 16:18 are 10:12
% 			newOrder = [1:9 16:17 10:15]; % 17, now that I took out the save button
% 			this.gui.RightBoxGrid.handle.Contents = this.gui.RightBoxGrid.handle.Contents(newOrder);
			
			% Update the local copy of currentRegion
			this.currentRegion = currentRegion;
		end
		
		% Dynamically called by State.Listener
		function [] = onCurrentRegionChange(this, state)
			% REDRAW TIMESERIES 
			this.redrawCurrentTimeseries(state);
			
			% Also sets this.currentRegion = currentRegion
			this.redrawRegionEditingArea(state);
		end
		
		function [] = redrawCurrentTimeseries(this, state)
			currentRegion = [];
			for iRegion = 1:numel(state.regions)
				if state.regions{iRegion}.id == state.currentRegion
					currentRegion = state.regions{iRegion};
					break;
				end
			end
			
			% If there's no mask, you can't have a timeseries
			if isempty(currentRegion) || isempty(currentRegion.mask)
				return;
			end
			
% 			% If you're not in editing mode, there's no currentTimeseries to
% 			% worry about (all the timeseries have already been displayed)
% 			% TODO: Maybe the selected region's timeseries should be moved up?
% 			% Otherwise, you won't get it in position when editing starts.
% 			if(~strcmp(state.isEditing, 'region'))
% 				return;
% 			end
			
			region = currentRegion;
			label = ['Timeseries' num2str(region.id)];
			if(isfield(this.gui, label))
				% If the timeseries with this id is already being displayed, just
				% update its plot
				this.gui.(label).updateTimeseries( ...
					region.timeseries, ...
					region.color, ...
					state.currentFrameNo, ...
					'Title', region.name ...
				);
			else
				% If there is no currently displayed timeseries with this id, append
				% it to the tab and move it to first position
				label = ['Timeseries' num2str(region.id)];
				containerLabel = [label 'Container'];
				this.gui.(containerLabel) = vt.Component.Container( ...
					this.gui.TimeSeriesTab, ...
					'Tag', num2str(region.id) ...
				);
				this.gui.(label) = vt.Component.Timeseries( ...
					this.gui.(containerLabel), ...
					region.timeseries, ...
					region.color, ...
					state.currentFrameNo, ...
					'Title', region.name, ...
					'Tag', num2str(region.id) ...
				);
				this.initializeComponent(this.gui.(containerLabel));
				this.initializeComponent(this.gui.(label));

				% Move the current timeseries to first position
				nTimeseries = numel(this.gui.TimeSeriesTab.handle.Contents);
				newOrder = [nTimeseries, 1:(nTimeseries-1)];
				this.gui.TimeSeriesTab.handle.Contents = this.gui.TimeSeriesTab.handle.Contents(newOrder);
			end
		end
	end
end