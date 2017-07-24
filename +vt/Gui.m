classdef Gui < handle
	properties
		state
		styles
		reducer
		gui
	end
	
	methods
		function [] = run(this)
			this.state = vt.State();
			this.reducer = vt.Reducer(this.state);
			this.styles = this.createStyles();
			this.gui = this.createInterface();
			
			this.state.initialize();
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
			gui.Window = vt.Window( 'VocalTract ROI Toolbox' );
			
			% + File menu
			gui.FileMenu = vt.MenuItem( gui.Window,   'File' );
			gui.LoadMenu = vt.MenuItem( gui.FileMenu, 'Load...' );
			gui.ExitMenu = vt.ExitMenuItem( gui.FileMenu, 'Exit' );
			gui.LoadAvi = vt.LoadMenuItem( gui.LoadMenu, 'AVI', 'avi' );
			gui.LoadVocalTract = vt.LoadMenuItem( gui.LoadMenu, 'VocalTract', 'VocalTract' );
			
			this.reducer.registerActionListener( gui.ExitMenu );
			this.reducer.registerActionListener( gui.LoadAvi );
			this.reducer.registerActionListener( gui.LoadVocalTract );

			% + Help menu
			gui.HelpMenu = vt.MenuItem( gui.Window, 'Help' );
			gui.DocumentationMenu = vt.HelpMenuItem( gui.HelpMenu, 'Documentation' );
			
			this.reducer.registerActionListener( gui.DocumentationMenu );

			% Arrange the main interface
			gui.MainLayout = vt.HBoxFlex( ...
				gui.Window, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.LeftBox = vt.VBox( ...
				gui.MainLayout, ...
				'Padding', this.styles.Padding, ...
				'Spacing', this.styles.Spacing ...
				);
			gui.LeftBoxImageContainer = vt.Container( ...
				gui.LeftBox ...
				);
			gui.LeftBoxImageControls  = vt.HBox( ...
				gui.LeftBox ...
				);
			gui.FrameDecrementControls = vt.HButtonBox( ...
				gui.LeftBoxImageControls, ...
				'HorizontalAlignment', 'left' ...
				);
			gui.FrameIncrementControls = vt.HButtonBox( ...
				gui.LeftBoxImageControls, ...
				'HorizontalAlignment', 'right' ...
				);

			% Can this be done when you're creating the object?
			gui.LeftBox.setParameters( 'Heights', [-1, 35] );

			gui.FrameImage = vt.Axes( gui.LeftBoxImageContainer );
			gui.FrameImage.registerStateListener( this.state, 'currentFrame' );
			
			gui.Decrement10Button = vt.IncrementButton( gui.FrameDecrementControls, '<<', -10 );
			gui.DecrementButton = vt.IncrementButton( gui.FrameDecrementControls, '<', -1 );
			gui.IncrementButton = vt.IncrementButton( gui.FrameIncrementControls, '>', 1 );
			gui.Increment10Button = vt.IncrementButton( gui.FrameIncrementControls, '>>', 10 );
			this.reducer.registerActionListener( gui.DecrementButton );
			this.reducer.registerActionListener( gui.Decrement10Button );
			this.reducer.registerActionListener( gui.IncrementButton );
			this.reducer.registerActionListener( gui.Increment10Button );


			% Can this be done when you're creating the object?
			gui.FrameDecrementControls.setParameters( 'ButtonSize', [70 35], 'Spacing', this.styles.Spacing + 2 );
			gui.FrameIncrementControls.setParameters( 'ButtonSize', [70 35], 'Spacing', this.styles.Spacing + 2 );
			
% 			this.reducer.addActionListener( LoadAviMenuItem, 'LOAD', 'avi' )
			loader = vt.VideoLoader();
			loader.registerStateListener( this.state, 'isLoading' );
			this.reducer.registerActionListener( loader );
		end
	end
end