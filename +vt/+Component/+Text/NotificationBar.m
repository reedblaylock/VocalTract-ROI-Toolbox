% This is the notification bar at the bottom of the GUI.
classdef NotificationBar < redux.Component.Text
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Call the parent constructor (a text object), and apply certain
		% parameters.
		function this = NotificationBar(parent)
			this@redux.Component.Text(parent);
			
			this.setParameters( ...
				'String', 'Welcome to the VocalTract ROI Toolbox!', ...
				'FontSize', 12, ...
				'HorizontalAlignment', 'left' ...
			);
		end
		
		%%%%% OTHER %%%%%
		
		% Update the text and color of the notification bar. Called exclusively
		% by Wrapper.NotificationBar.
		function [] = update(this, string, color)
			this.setParameters( ...
				'String', string, ...
				'BackgroundColor', color ...
			);
		end
	end
	
end

