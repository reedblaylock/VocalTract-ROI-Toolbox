classdef NotificationBar < vt.Component.Text
	properties
	end
	
	methods
		function this = NotificationBar(parent)
			this@vt.Component.Text(parent);
			
			this.setParameters( ...
				'String', 'Welcome to the VocalTract ROI Toolbox!', ...
				'FontSize', 16, ...
				'HorizontalAlignment', 'left' ...
			);
		end
		
		function [] = update(this, string, color)
			try
				this.setParameters( ...
					'String', string, ...
					'BackgroundColor', color ...
				);
			catch err
% 				keyboard;
				disp('The error was here!');
				err
			end
		end
	end
	
end

