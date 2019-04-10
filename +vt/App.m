% This class is initialized in runGui.m. The constructor function creates a Log
% object and initializes it; the run function creates a set of pseudo-global
% objects, creates the GUI components, sets up the connections between the GUI
% components and their functionality, and disables most interface capabilities
% until a video is loaded.
classdef App < redux.App
	properties
		% TODO: get this from user-specified preferences
		currentRegion = struct('shape', 'Circle')
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
			
% 		`	gui.MainLayout, ...
%			gui.LeftBoxPanel, ...
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
			% TODO: this box might be superfluous
			gui.RegionSettingsTab = redux.Component.Layout.HBox( ...
				gui.RightBox, ...
				'Padding', this.styles.Padding, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.TimeSeriesTab = redux.Component.Layout.VBox( ...
				gui.RightBox, ...
				'Padding', this.styles.Padding, ...
				'Spacing', this.styles.Spacing ...
			);
			gui.RightBox.setParameters('TabTitles', {'Region settings', 'Timeseries'});
			
			%%% Region settings panel
			gui = vt.Component.Layout.RegionSettings.renderRegionSettingsGrid(gui);
            
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

					this.gui.(containerLabel) = redux.Component.Container( ...
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
			
% 			gui.ExitMenu = vt.Component.MenuItem.Exit( gui.FileMenu, 'Exit' );

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
		
		function [] = redrawCurrentTimeseries(this, state)
			curRegion = [];
			for iRegion = 1:numel(state.regions)
				if state.regions{iRegion}.id == state.currentRegion
					curRegion = state.regions{iRegion};
					break;
				end
			end
			
			% If there's no mask, you can't have a timeseries
			if isempty(curRegion) || isempty(curRegion.mask)
				return;
			end
			
% 			% If you're not in editing mode, there's no currentTimeseries to
% 			% worry about (all the timeseries have already been displayed)
% 			% TODO: Maybe the selected region's timeseries should be moved up?
% 			% Otherwise, you won't get it in position when editing starts.
% 			if(~strcmp(state.isEditing, 'region'))
% 				return;
% 			end
			
			region = curRegion;
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
				this.gui.(containerLabel) = redux.Component.Container( ...
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