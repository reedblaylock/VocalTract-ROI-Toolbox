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

			% Explicitly call the demo display so that it gets included if we deploy
			% ...this function seems to do nothing.
% 			displayEndOfDemoMessage('')
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
			gui.ExitMenu = vt.MenuItem( gui.FileMenu, 'Exit', 'CLOSE_GUI' );
			gui.LoadAVI  = vt.MenuItem( gui.LoadMenu, 'AVI', 'LOAD_AVI' );
			gui.LoadVocalTract = vt.MenuItem( gui.LoadMenu, 'VocalTract', 'LOAD_VOCAL_TRACT' );
			
			this.reducer.registerActionListener( gui.ExitMenu, 'CLOSE_GUI' );
			this.reducer.registerActionListener( gui.LoadAVI, 'LOAD_AVI' );
			this.reducer.registerActionListener( gui.LoadVocalTract, 'LOAD_VOCAL_TRACT' );

			% + Help menu
			gui.HelpMenu = vt.MenuItem( gui.Window, 'Help' );
			gui.DocumentationMenu = vt.MenuItem( gui.HelpMenu, 'Documentation', 'HELP');
			
			this.reducer.registerActionListener( gui.DocumentationMenu, 'HELP' );

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
			this.reducer.registerActionListener( gui.DecrementButton, 'INCREMENT' );
			this.reducer.registerActionListener( gui.Decrement10Button, 'INCREMENT' );
			this.reducer.registerActionListener( gui.IncrementButton, 'INCREMENT' );
			this.reducer.registerActionListener( gui.Increment10Button, 'INCREMENT' );
			
% 			gui.DecrementButton = vt.Button( gui.FrameDecrementControls, '<', 'DECREMENT' );
% 			gui.IncrementButton = vt.Button( gui.FrameIncrementControls, '>', 'INCREMENT' );
% 			this.reducer.registerActionListener( gui.DecrementButton, 'DECREMENT' );
% 			this.reducer.registerActionListener( gui.IncrementButton, 'INCREMENT' );


			% Can this be done when you're creating the object?
			gui.FrameDecrementControls.setParameters( 'ButtonSize', [70 35], 'Spacing', this.styles.Spacing + 2 );
			gui.FrameIncrementControls.setParameters( 'ButtonSize', [70 35], 'Spacing', this.styles.Spacing + 2 );
			
% 			this.reducer.addActionListener( LoadAviMenuItem, 'LOAD', 'avi' )
			loader = vt.VideoLoader();
			loader.registerStateListener( this.state, 'isLoading' )
			this.reducer.registerActionListener( Loader, 'SET_VIDEO_DATA' )
			
			% https://stackoverflow.com/questions/31988224/how-to-set-listener-to-a-matlab-objects-structures-field
% 			video = vt.Video();
% 			video.registerStateListener( this.state, 'isLoading' );
		end
	end
end