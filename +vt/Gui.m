classdef Gui < vt.Root
	properties
		state
		styles
		reducer
		gui
	end
	
	methods
		function [] = run(this)
			this.log.on();
			
			this.state = vt.State();
			this.reducer = vt.Reducer(this.state);
			this.styles = this.createStyles();
			this.gui = this.createInterface();
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
			
			% Open a window and add some menus
			gui.Window = vt.Component.Window( 'VocalTract ROI Toolbox' );
			gui.Window.registerStateListener( this.state, 'video' );
			
			% + File menu
			gui.FileMenu = vt.Component.MenuItem( gui.Window,   'File' );
			gui.LoadMenu = vt.Component.MenuItem( gui.FileMenu, 'Load...' );
			gui.ExitMenu = vt.Component.MenuItem.Exit( gui.FileMenu, 'Exit' );
			gui.LoadAvi = vt.MenuItem.Load( gui.LoadMenu, 'AVI', 'avi' );
% 			gui.LoadVocalTract = vt.LoadMenuItem( gui.LoadMenu, 'VocalTract', 'VocalTract' );
			
% 			this.reducer.registerActionListener( gui.ExitMenu );
% 			this.reducer.registerActionListener( gui.LoadAvi );
% 			this.reducer.registerActionListener( gui.LoadVocalTract );

			% + Help menu
			gui.HelpMenu = vt.MenuItem( gui.Window, 'Help' );
			gui.DocumentationMenu = vt.MenuItem.Help( gui.HelpMenu, 'Documentation' );
			
% 			this.reducer.registerActionListener( gui.DocumentationMenu );

			% Arrange the main interface
			gui.MainLayoutWrapper = vt.Component.Layout.VBoxFlex( ...
				gui.Window, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.MainLayout = vt.Component.Layout.HBoxFlex( ...
				gui.MainLayoutWrapper, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.NotificationBar = vt.Component.Text.NotificationBar( ...
				gui.MainLayoutWrapper ...
			);
			gui.MainLayoutWrapper.setParameters('Heights', [-15, -1]);
			gui.LeftBox = vt.Component.Layout.VBox( ...
				gui.MainLayout, ...
				'Padding', this.styles.Padding, ...
				'Spacing', this.styles.Spacing ...
				);
			gui.LeftBoxImageContainer = vt.Component.Container( ...
				gui.LeftBox ...
				);
			gui.LeftBoxImageControls  = vt.Component.Layout.HBox( ...
				gui.LeftBox ...
				);
			gui.FrameDecrementControls = vt.Component.Layout.HButtonBox( ...
				gui.LeftBoxImageControls, ...
				'HorizontalAlignment', 'left' ...
				);
			gui.FrameIncrementControls = vt.Component.Layout.HButtonBox( ...
				gui.LeftBoxImageControls, ...
				'HorizontalAlignment', 'right' ...
				);

			% Can this be done when you're creating the object?
			gui.LeftBox.setParameters( 'Heights', [-1, 35] );

			gui.Frame = vt.Component.Frame( gui.LeftBoxImageContainer );
			frameContainer = vt.Container.Frame( gui.Frame );
			frameContainer.registerStateListener( this.state, {'currentFrameNo', 'video'} );
			
			gui.Decrement10Button = vt.IncrementButton( gui.FrameDecrementControls, '<<', -10 );
			gui.DecrementButton = vt.IncrementButton( gui.FrameDecrementControls, '<', -1 );
			gui.IncrementButton = vt.IncrementButton( gui.FrameIncrementControls, '>', 1 );
			gui.Increment10Button = vt.IncrementButton( gui.FrameIncrementControls, '>>', 10 );
% 			this.reducer.registerActionListener( gui.DecrementButton );
% 			this.reducer.registerActionListener( gui.Decrement10Button );
% 			this.reducer.registerActionListener( gui.IncrementButton );
% 			this.reducer.registerActionListener( gui.Increment10Button );

			% Can this be done when you're creating the object?
			gui.FrameDecrementControls.setParameters( 'ButtonSize', [70 35], 'Spacing', this.styles.Spacing + 2 );
			gui.FrameIncrementControls.setParameters( 'ButtonSize', [70 35], 'Spacing', this.styles.Spacing + 2 );
		end
		
		function [] = delete(~)
			disp('GUI is being deleted');
		end
	end
end