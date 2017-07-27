classdef Window < vt.Component & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.CloseGuiAction
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
		
			this.setCallback('CloseRequestFcn');
		end
	end
	
end

