classdef Window < vt.Component
	% This class has a default callback. Closing figures is often more trouble
	% than it's worth, so avoid doing a custom job. If you want to see an
	% example of a custom window callback, see the Exit button and
	% vt.Reducer.closeGui().
	
	methods
		function this = Window(name)
			p = vt.InputParser();
			p.addRequired('name', @ischar);
			p.parse(name);
			
			this.handle = figure( ...
				'Name', p.Results.name, ...
				'NumberTitle', 'off', ...
				'MenuBar', 'none', ...
				'Toolbar', 'none' ...
			);
		end
	end
	
end

