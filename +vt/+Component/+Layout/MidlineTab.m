classdef MidlineTab < redux.Component.Layout.VBox & redux.State.Listener
	
	properties
		gui
		styles
		panelIds
	end
	
	methods
		function this = MidlineTab(parent, styles)
			this@redux.Component.Layout.VBox( ...
				parent, ...
				'Padding', styles.Padding, ...
				'Spacing', styles.Spacing ...
			);
		
			this.panelIds = struct();
			this.styles = styles;
        end
        
        % card panel with...
        % - a button to make the midline
        % - a button to re-make midline?
        % - a field for changing radius
        % - a field for changing color
        
        % also need a different visualization in the timeseries tab
        
        function gui = render(this, gui)
			gui = this.renderRegionConstants(this, gui);
			gui = this.renderRegionParameters(this, gui);
			gui = this.renderRegionDisplay(this, gui);
			gui = this.renderRegionButtons(this, gui);
			
			this.gui = gui;
		end
    end
end