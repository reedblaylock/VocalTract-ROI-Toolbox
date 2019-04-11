% This class is initialized in runGui.m. The constructor function creates a Log
% object and initializes it; the run function creates a set of pseudo-global
% objects, creates the GUI components, sets up the connections between the GUI
% components and their functionality, and disables most interface capabilities
% until a video is loaded.
classdef App < redux.App
	properties
	end
	
	methods
		function this = App(varargin)
			p = inputParser;
			addOptional(p, 'debugSetting', 0);
			parse(p, varargin{:});
			
			this@redux.App(p.Results.debugSetting);
		end
		
		% Create the GUI.
		function gui = createInterface(this)
			% Create the user interface for the application and return a
			% structure of handles for global use.
			gui = struct();
			
			% Open a window
			gui.Window = redux.Component.Window.App( 'VocalTract ROI Toolbox' );
			
			% Add menu
			gui = this.renderMenu(gui);
			
			% Add components
			gui = this.renderComponents(gui);
		end
		
		function gui = renderComponents(this, gui)
			% Arrange the main interface
			gui.MainLayoutWrapper = redux.Component.Layout.VBoxFlex( ...
				gui.Window, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.MainLayout = redux.Component.Layout.HBoxFlex( ...
				gui.MainLayoutWrapper, ...
				'Spacing', this.styles.Spacing ...
			);
			
			% + Notification bar
			gui = this.renderNotificationBar(gui);
			
			% Set the relative sizing between the notification bar and the rest
			% of the interface
			gui.MainLayoutWrapper.setParameters('Heights', [-15, -1]);
			
			% + Image
			gui.LeftBoxPanel = redux.Component.Layout.BoxPanel( ...
				gui.MainLayout, ...
				'Title', 'Video', ...
				'Padding', this.styles.Padding ...
			);
			
 			gui.LeftBox = redux.Component.Layout.VBox( ...
				gui.LeftBoxPanel, ...
				'Padding', this.styles.Padding, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.LeftBoxImageContainer = redux.Component.Container( ...
				gui.LeftBox ...
			);
			
			% + Image controls
			gui = this.renderImageControls(gui);
			
			% + Right panels
			gui.RightBox = redux.Component.Layout.TabPanel( ...
				gui.MainLayout, ...
				'TabWidth', 100, ...
				'Padding', this.styles.Padding ...
			);
			
			%%% Render tabs
			% First, get objects for the tab contents
			
 			% TODO: Is the problem that these aren't part of the gui explicitly?
			gui.RegionSettingsTab = vt.Component.Layout.RegionSettingsTab(gui.RightBox, this.styles);
			gui.TimeseriesArray = vt.Component.Wrapper.TimeseriesArray(gui.RightBox, this.styles);
			% Then, render each tab's contents. The gui fields are defined
			% inside the object's render function, which is maybe smelly code?
			gui = gui.RegionSettingsTab.render(gui.RegionSettingsTab, gui);
			gui = gui.TimeseriesArray.render(gui);
			
			gui.RightBox.setParameters('TabTitles', {'Regions', 'Timeseries'});
            
            % Make sure Regions tab is the currently open one
            gui.RightBox.setParameters('Selection', 1);
		end
		
		function gui = renderMenu(~, gui)
			% + File menu
			gui.FileMenu = redux.Component.MenuItem( gui.Window,   'File' );
			
			% + Video menus
			gui.VideoMenu = redux.Component.MenuItem( gui.FileMenu, 'Video...' );
			gui.LoadAvi   = vt.Component.MenuItem.Load( gui.VideoMenu, 'Load AVI', 'avi' );
			
			% + Region menus
			gui.RegionMenu = redux.Component.MenuItem( gui.FileMenu, 'Regions...' );
			gui.ExportRegions = vt.Component.MenuItem.ExportRegions( gui.RegionMenu, 'Export regions' );
			gui.ImportRegions = vt.Component.MenuItem.ImportRegions( gui.RegionMenu, 'Import regions' );
			
			gui.Export   = vt.Component.MenuItem.Export( gui.FileMenu, 'Export for mview' );
			gui.ExportFrame = vt.Component.MenuItem.ExportFrame ( gui.FileMenu, 'Export frame to jpg' );
			
			% + Help menu
			gui.HelpMenu = redux.Component.MenuItem( gui.Window, 'Help' );
			gui.DocumentationMenu = vt.Component.MenuItem.Help( gui.HelpMenu, 'Documentation' );
		end
		
		function gui = renderNotificationBar(~, gui)
			gui.NotificationBar = vt.Component.Text.NotificationBar( ...
				gui.MainLayoutWrapper ...
			);
			gui.NotificationBarWrapper = vt.Component.Wrapper.NotificationBar( ...
				gui.NotificationBar ...
			);
		end
		
		function gui = renderImageControls(this, gui)
			gui.LeftBoxFrameControls = redux.Component.Layout.VBox( ...
				gui.LeftBox ...
			);
			gui.LeftBoxFrameNoControls  = redux.Component.Layout.HBox( ...
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
			gui.FrameTypeButtonBox = redux.Component.Layout.HButtonBox( ...
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
	end
end