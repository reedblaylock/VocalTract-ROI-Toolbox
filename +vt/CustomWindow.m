classdef CustomWindow < vt.Component & ActionDispatcherWithoutData
	properties
	end
	
	events
		% This event ends up calling the default figure-closing action @closereq
		% (see vt.Reducer.closeGui for the implementation). If you want to
		% implement your own closing function, replace CLOSE_GUI with your own
		% action (in all-caps). Then, write the corresponding logic in
		% vt.Reducers or your own custom reducer.
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
		
			this.setCallback('CloseRequestFcn');
		end
	end
	
end

