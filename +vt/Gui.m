% This class is initialized in runGui.m. The constructor function creates a Log
% object and initializes it; the run function creates a set of pseudo-global
% objects, creates the GUI components, sets up the connections between the GUI
% components and their functionality, and disables most interface capabilities
% until a video is loaded.
classdef Gui < vt.Root & vt.State.Listener
	properties
		state
		styles
		reducer
		gui
		actionListener
		
		% TODO: get this from user-specified preferences
		currentRegion = struct('shape', 'Circle')
	end
	
	methods
		function this = Gui()
			this.log = vt.Log(2);
			this.log.on();
		end
		
		function [] = run(this)
			this.state = vt.State();
			this.reducer = vt.Reducer(this.state);
			this.actionListener = vt.Action.Listener(this.reducer);
			
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
					this.actionListener.registerAction(obj.action);
				end
			end
			
			% Give all the properties of this vt.Gui a log as well
			propertyList = properties(this);
			for iProp = 1:numel(properties(this))
				prop = propertyList{iProp};
				if(isa(this.(prop), 'vt.Root'))
					this.(prop).log = this.log;
				end
			end
			
			% Register vt.Gui as a state listener
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
				this.actionListener.registerAction(obj.action);
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
			if(isempty(fieldnames(state.regions)) || ~numel(state.regions))
				% There are no regions to draw
				return;
			end
			
			for iRegion = 1:numel(state.regions)
				region = state.regions(iRegion);
				label = ['Timeseries' num2str(region.id)];
				containerLabel = [label 'Container'];
				
				this.gui.(containerLabel) = vt.Component.Container( ...
					this.gui.TimeSeriesTab, ...
					'Tag', num2str(region.id) ...
				);
				this.gui.(label) = vt.Component.Timeseries( ...
					this.gui.(containerLabel), ...
					state.timeseries(iRegion).data, ...
					region.color, ...
					state.currentFrameNo, ...
					'Title', region.name, ...
					'Tag', num2str(region.id) ...
				);
				this.initializeComponent(this.gui.(containerLabel));
				this.initializeComponent(this.gui.(label));
			end
		end
		
		function [] = onRegionsChange(this, state)
			% You should probably show currentRegion's timeseries too. Maybe you
			% can color the back panel differently to indicate that it's
			% temporary, somehow?
			
			% TODO: order display by (xcoordinate + ycoordinate) increasing
			
			this.deleteAllTimeseries(state);
			this.redrawAllTimeseries(state);
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
			
			gui.ExitMenu = vt.Component.MenuItem.Exit( gui.FileMenu, 'Exit' );

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
			% 1-2 + Radius
			gui.RegionSettings1_2 = vt.Component.Layout.Panel( ...
				gui.RightBoxGrid, ...
				'Title', 'Radius' ...
			);
			gui.RegionRadius = vt.Component.TextBox.Radius( ...
				gui.RegionSettings1_2 ...
			);
			% 2-2 + Empty space
			gui.RegionSettings2_2 = vt.Component.Layout.Empty( ...
				gui.RightBoxGrid ...
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
			gui.RegionSettings7_2 = vt.Component.Button.NewRegion( ...
				gui.RightBoxGrid, ...
				'New region' ...
			);
			% 8-2 + Edit region
			gui.RegionSettings8_2 = vt.Component.Button.EditRegion( ...
				gui.RightBoxGrid, ...
				'Edit region' ...
			);
			% 9-2 + Delete region
			gui.RegionSettings9_2 = vt.Component.Button.DeleteRegion( ...
				gui.RightBoxGrid, ...
				'Delete region' ...
			);
			
			gui.RightBoxGrid.setParameters('Widths', [-1 -1], 'Heights', -1.*ones(1, 9));
		end
		
		function [] = onIsEditingChange(this, state)
			switch(state.isEditing)
				case 'region'
					% delete the last three areas
					delete(this.gui.RightBoxGrid.handle.Contents(16:18));
					delete(this.gui.RegionSettings7_2);
					delete(this.gui.RegionSettings8_2);
					delete(this.gui.RegionSettings9_2);
					this.gui.RegionSettings7_2 = [];
					this.gui.RegionSettings8_2 = [];
					this.gui.RegionSettings9_2 = [];
					this.gui = rmfield(this.gui, 'RegionSettings7_2');
					this.gui = rmfield(this.gui, 'RegionSettings8_2');
					this.gui = rmfield(this.gui, 'RegionSettings9_2');
					
					% add the save, delete, and cancel buttons
					% 7-2 + Save button
					this.gui.RegionSettings7_2 = vt.Component.Button.SaveRegion( ...
						this.gui.RightBoxGrid, ...
						'Save region' ...
					);
					this.initializeComponent(this.gui.RegionSettings7_2);
					% 8-2 + Delete button
					this.gui.RegionSettings8_2 = vt.Component.Button.DeleteRegion( ...
						this.gui.RightBoxGrid, ...
						'Delete region' ...
					);
					this.initializeComponent(this.gui.RegionSettings8_2);
					% 9-2 + Cancel button
					this.gui.RegionSettings9_2 = vt.Component.Button.CancelRegion( ...
						this.gui.RightBoxGrid, ...
						'Cancel region changes' ...
					);
					this.initializeComponent(this.gui.RegionSettings9_2);
				
					% re-order
					% Not necessary at the moment, because these items go on the
					% end
				otherwise
					% Not in any editing mode
					% delete and re-draw all timeseries
					this.deleteAllTimeseries(state);
					this.redrawAllTimeseries(state);
					
					% delete the last three areas
					delete(this.gui.RightBoxGrid.handle.Contents(16:18));
					delete(this.gui.RegionSettings7_2);
					delete(this.gui.RegionSettings8_2);
					delete(this.gui.RegionSettings9_2);
					this.gui.RegionSettings7_2 = [];
					this.gui.RegionSettings8_2 = [];
					this.gui.RegionSettings9_2 = [];
					this.gui = rmfield(this.gui, 'RegionSettings7_2');
					this.gui = rmfield(this.gui, 'RegionSettings8_2');
					this.gui = rmfield(this.gui, 'RegionSettings9_2');
					
					% 7-2 + New region
					this.gui.RegionSettings7_2 = vt.Component.Button.NewRegion( ...
						this.gui.RightBoxGrid, ...
						'New region' ...
					);
					this.initializeComponent(this.gui.RegionSettings7_2);
					% 8-2 + Edit region
					this.gui.RegionSettings8_2 = vt.Component.Button.EditRegion( ...
						this.gui.RightBoxGrid, ...
						'Edit region' ...
					);
					% If there is a current region, keep the button on
					if(isfield(state.currentRegion, 'id') && ~isempty(state.currentRegion.id))
						this.gui.RegionSettings8_2.setParameters('Enable', 'on');
					else
						this.gui.RegionSettings8_2.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings8_2);
					% 9-2 + Delete region
					this.gui.RegionSettings9_2 = vt.Component.Button.DeleteRegion( ...
						this.gui.RightBoxGrid, ...
						'Delete region' ...
					);
					% If there is a current region, keep the button on
					if(isfield(state.currentRegion, 'id') && ~isempty(state.currentRegion.id))
						this.gui.RegionSettings9_2.setParameters('Enable', 'on');
					else
						this.gui.RegionSettings9_2.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings9_2);
					
					% re-order
					% Not necessary, since these elements are getting appended
					% to the end anyway
			end
		end
		
		% Dynamically called by State.Listener
		function [] = onCurrentRegionChange(this, state)
			% REDRAW TIMESERIES 
			this.redrawCurrentTimeseries(state);
			
			% REDRAW REGION EDITING AREA
			% Prevent re-drawing when other changes than shape changes are made
			if(strcmp(this.currentRegion.shape, state.currentRegion.shape))
				return;
			end
			
			% Delete whatever parameter fields are currently present. The calls
			% to delete() are the most important
			% 1. Delete seems to be the only thing that works
			% 2. When vt.State.Listeners are deleted, they first delete their
			%    own listener handles
			delete(this.gui.RightBoxGrid.handle.Contents(10:12));
			switch(this.currentRegion.shape)
				case 'Circle'
					delete(this.gui.RegionRadius);
					this.gui.RegionSettings1_2 = [];
					this.gui.RegionSettings2_2 = [];
					this.gui.RegionSettings3_2 = [];
					this.gui.RegionRadius = [];
					this.gui = rmfield(this.gui, 'RegionSettings1_2');
					this.gui = rmfield(this.gui, 'RegionSettings2_2');
					this.gui = rmfield(this.gui, 'RegionSettings3_2');
					this.gui = rmfield(this.gui, 'RegionRadius');
				case 'Rectangle'
					delete(this.gui.RegionWidth);
					delete(this.gui.RegionHeight);
					this.gui.RegionSettings1_2 = [];
					this.gui.RegionSettings2_2 = [];
					this.gui.RegionSettings3_2 = [];
					this.gui.RegionWidth = [];
					this.gui.RegionHeight = [];
					this.gui = rmfield(this.gui, 'RegionSettings1_2');
					this.gui = rmfield(this.gui, 'RegionSettings2_2');
					this.gui = rmfield(this.gui, 'RegionSettings3_2');
					this.gui = rmfield(this.gui, 'RegionWidth');
					this.gui = rmfield(this.gui, 'RegionHeight');
				case 'Statistically-generated'
					delete(this.gui.MinimumPixels);
					delete(this.gui.SearchRadius);
					delete(this.gui.Tau);
					this.gui.RegionSettings1_2 = [];
					this.gui.RegionSettings2_2 = [];
					this.gui.RegionSettings3_2 = [];
					this.gui.MinimumPixels = [];
					this.gui.SearchRadius = [];
					this.gui.Tau = [];
					this.gui = rmfield(this.gui, 'RegionSettings1_2');
					this.gui = rmfield(this.gui, 'RegionSettings2_2');
					this.gui = rmfield(this.gui, 'RegionSettings3_2');
					this.gui = rmfield(this.gui, 'MinimumPixels');
					this.gui = rmfield(this.gui, 'SearchRadius');
					this.gui = rmfield(this.gui, 'Tau');
				otherwise
					% TODO: something here
			end
			
			% TODO: If isEditing='region', 'Enable'='on'; otherwise,
			% 'Enable'='off'
			switch(state.currentRegion.shape)
				case 'Circle'
					% 1-2 + Radius
					this.gui.RegionSettings1_2 = vt.Component.Layout.Panel( ...
						this.gui.RightBoxGrid, ...
						'Title', 'Radius' ...
					);
					this.gui.RegionRadius = vt.Component.TextBox.Radius( ...
						this.gui.RegionSettings1_2, ...
						'String', num2str(state.currentRegion.radius) ...
					);
					if(~strcmp(state.isEditing, 'region'))
						this.gui.RegionRadius.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings1_2);
					this.initializeComponent(this.gui.RegionRadius);
					% 2-2 + Empty space
					this.gui.RegionSettings2_2 = vt.Component.Layout.Empty( ...
						this.gui.RightBoxGrid ...
					);
					this.initializeComponent(this.gui.RegionSettings2_2);
					% 3-2 + Empty space
					this.gui.RegionSettings3_2 = vt.Component.Layout.Empty( ...
						this.gui.RightBoxGrid ...
					);
					this.initializeComponent(this.gui.RegionSettings3_2);
				case 'Rectangle'
					% 1-2 + Width
					this.gui.RegionSettings1_2 = vt.Component.Layout.Panel( ...
						this.gui.RightBoxGrid, ...
						'Title', 'Width' ...
					);
					this.gui.RegionWidth = vt.Component.TextBox.Width( ...
						this.gui.RegionSettings1_2, ...
						'String', num2str(state.currentRegion.width) ...
					);
					if(~strcmp(state.isEditing, 'region'))
						this.gui.RegionWidth.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings1_2);
					this.initializeComponent(this.gui.RegionWidth);
					% 2-2 + Height
					this.gui.RegionSettings2_2 = vt.Component.Layout.Panel( ...
						this.gui.RightBoxGrid, ...
						'Title', 'Height' ...
					);
					this.gui.RegionHeight = vt.Component.TextBox.Height( ...
						this.gui.RegionSettings2_2, ...
						'String', num2str(state.currentRegion.height) ...
					);
					if(~strcmp(state.isEditing, 'region'))
						this.gui.RegionHeight.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings2_2);
					this.initializeComponent(this.gui.RegionHeight);
					% 3-2 + Empty space
					this.gui.RegionSettings3_2 = vt.Component.Layout.Empty( ...
						this.gui.RightBoxGrid ...
					);
					this.initializeComponent(this.gui.RegionSettings3_2);
				case 'Statistically-generated'
					% 1-2 + Minimum # pixels textbox
					this.gui.RegionSettings1_2 = vt.Component.Layout.Panel( ...
						this.gui.RightBoxGrid, ...
						'Title', 'Minimum number of pixels' ...
					);
					this.gui.MinimumPixels = vt.Component.TextBox.MinimumPixels( ...
						this.gui.RegionSettings1_2, ...
						'String', num2str(state.currentRegion.minimumPixels) ...
					);
					if(~strcmp(state.isEditing, 'region'))
						this.gui.MinimumPixels.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings1_2);
					this.initializeComponent(this.gui.MinimumPixels);
					% 2-2 + Search radius textbox
					this.gui.RegionSettings2_2 = vt.Component.Layout.Panel( ...
						this.gui.RightBoxGrid, ...
						'Title', 'Search radius' ...
					);
					this.gui.SearchRadius = vt.Component.TextBox.SearchRadius( ...
						this.gui.RegionSettings2_2, ...
						'String', num2str(state.currentRegion.searchRadius) ...
					);
					if(~strcmp(state.isEditing, 'region'))
						this.gui.SearchRadius.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings2_2);
					this.initializeComponent(this.gui.SearchRadius);
					% 3-2 + Tau textbox
					this.gui.RegionSettings3_2 = vt.Component.Layout.Panel( ...
						this.gui.RightBoxGrid, ...
						'Title', 'Tau' ...
					);
					this.gui.Tau = vt.Component.TextBox.Tau( ...
						this.gui.RegionSettings3_2, ...
						'String', num2str(state.currentRegion.tau) ...
					);
					if(~strcmp(state.isEditing, 'region'))
						this.gui.Tau.setParameters('Enable', 'off');
					end
					this.initializeComponent(this.gui.RegionSettings3_2);
					this.initializeComponent(this.gui.Tau);
				otherwise
					% TODO: add the rest
			end
			
			% re-order the elements so that elements 16:18 are 10:12
			newOrder = [1:9 16:18 10:15];
			this.gui.RightBoxGrid.handle.Contents = this.gui.RightBoxGrid.handle.Contents(newOrder);
			
			% Update the local copy of currentRegion
			this.currentRegion = state.currentRegion;
		end
		
		function [] = redrawCurrentTimeseries(this, state)
			% If there's no mask, you can't have a timeseries
			if(isempty(state.currentRegion.mask))
				return;
			end
			
% 			% If you're not in editing mode, there's no currentTimeseries to
% 			% worry about (all the timeseries have already been displayed)
% 			% TODO: Maybe the selected region's timeseries should be moved up?
% 			% Otherwise, you won't get it in position when editing starts.
% 			if(~strcmp(state.isEditing, 'region'))
% 				return;
% 			end
			
			region = state.currentRegion;
			label = ['Timeseries' num2str(region.id)];
			if(isfield(this.gui, label))
				% If the timeseries with this id is already being displayed, just
				% update its plot
				this.gui.(label).updateTimeseries( ...
					state.currentTimeseries.data, ...
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
					state.currentTimeseries.data, ...
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