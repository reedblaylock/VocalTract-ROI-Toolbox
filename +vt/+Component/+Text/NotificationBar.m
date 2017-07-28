classdef NotificationBar < vt.Component.Text
	properties
	end
	
	methods
		function this = NotificationBar(parent)
			this@vt.Component.Text(parent);
			
			this.setParameters( ...
				'String', 'Welcome to the VocalTract ROI Toolbox!', ...
				'FontSize', 12, ...
				'HorizontalAlignment', 'left' ...
			);
		end
		
		function [] = update(this, string, color)
			this.setParameters( ...
				'String', string, ...
				'BackgroundColor', color ...
			);
		end
	end
	
end

