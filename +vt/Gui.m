classdef Gui < vt.Root
	properties
		state
		styles
		reducer
		gui
		actionListener
	end
	
	methods
		function this = Gui()
			this.log = vt.Log(1);
			this.log.on();
		end
		
		function [] = run(this)
			this.state = vt.State();
			this.reducer = vt.Reducer(this.state);
			this.actionListener = vt.Action.Listener(this.reducer);
			
			this.styles = this.createStyles();
			this.gui = this.createInterface();
			
			this.initializeListeners();
		end
		
		function [] = initializeListeners(this)
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
			
			propertyList = properties(this);
			for iProp = 1:numel(properties(this))
				prop = propertyList{iProp};
				if(isa(this.(prop), 'vt.Root'))
					this.(prop).log = this.log;
				end
			end
		end
		
		function styles = createStyles(~)
			styles = struct( ...
				'Padding', 3, ...
				'Spacing', 3 ...
			);
		end
		
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
			
			gui.RegionSelectionArea = vt.Component.Layout.VBox( ...
				gui.RegionSettingsTab ...
			);
			
			% + Region Shape popup (drop-down) menu
			gui.RegionShapePanel = vt.Component.Layout.Panel( ...
				gui.RegionSelectionArea, ...
				'Title', 'Region shape' ...
			);
			gui.RegionShapePopup = vt.Component.Popup.RegionShape( ...
				gui.RegionShapePanel ...
			);
		
			% + Region Type popup (drop-down) menu
			gui.RegionTypePanel = vt.Component.Layout.Panel( ...
				gui.RegionSelectionArea, ...
				'Title', 'Region type' ...
			);
			gui.RegionTypePopup = vt.Component.Popup.RegionType( ...
				gui.RegionTypePanel ...
			);
		
			gui.RegionDetails = vt.Component.Layout.VBox( ...
				gui.RegionSettingsTab ...
			);
			gui.RegionNamePanel = vt.Component.Layout.Panel( ...
				gui.RegionDetails, ...
				'Title', 'Region name' ...
			);
			gui.RegionName = vt.Component.TextBox.RegionName( ...
				gui.RegionNamePanel ...
			);
		
			% + Add region color picker (vt.Component.Button.RegionColor)
			
			% + Add show region outline checkbox or toggle
			% + Add show region origin checkbox or toggle
			% + Add shade region checkbox or toggle
			% ...and find a way to make it possible to set all regions at once,
			%    or just some (maybe a show all toggle)
			
			% + Add a delete region button
		end
		
		function gui = addMenu(~, gui)
			% + File menu
			gui.FileMenu = vt.Component.MenuItem( gui.Window,   'File' );
			gui.LoadMenu = vt.Component.MenuItem( gui.FileMenu, 'Load...' );
			gui.ExitMenu = vt.Component.MenuItem.Exit( gui.FileMenu, 'Exit' );
			gui.LoadAvi  = vt.Component.MenuItem.Load( gui.LoadMenu, 'AVI', 'avi' );

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
			gui.FrameTypeControls = vt.Component.ButtonGroup.FrameType( ...
				gui.LeftBoxFrameControls ...
			);

			% Can this be done when you're creating the object?
			gui.LeftBox.setParameters( 'Heights', [-1, 35], 'Padding', this.styles.Padding );

			gui.Frame = vt.Component.Frame( gui.LeftBoxImageContainer );
			gui.frameContainer = vt.Component.Wrapper.Frame( gui.Frame );
		end
		
		function [] = delete(~)
			disp('GUI is being deleted');
		end
	end
end