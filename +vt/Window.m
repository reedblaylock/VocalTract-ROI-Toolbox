classdef Window < vt.Component;
	properties
	end
	
	events
		CLOSE_GUI
	end
	
	methods
		function this = Window(name, varargin)
			p = vt.InputParser();
			p.addRequired('name', @ischar);
			p.addOptionalAction();
			p.parse(name, varargin{:});
			
			this.handle = figure( ...
				'Name', p.Results.name, ...
				'NumberTitle', 'off', ...
				'MenuBar', 'none', ...
				'Toolbar', 'none' ...
			);
% 				'HandleVisibility', 'off' ...
		
			this.setCallbackName()
			
			% Defaults to the standard @closereq function for all figures.
			if(~isempty(p.Results.action))
				this.setCallback(p.Results.action);
			end
		end
		
		function [] = setCallbackName(this)
			this.callbackName = 'CloseRequestFcn';
		end
	end
	
end

