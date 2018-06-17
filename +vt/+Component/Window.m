classdef Window < vt.Component
	% This class has a default callback. Closing figures is often more trouble
	% than it's worth, so avoid doing a custom job.
	
	properties
		baseName
	end
	
	methods
		function this = Window(name)
			p = vt.InputParser();
			p.addRequired('name', @ischar);
			p.parse(name);
			
			this.baseName = p.Results.name;
			
			this.handle = figure( ...
				'Name', this.baseName, ...
				'NumberTitle', 'off', ...
				'MenuBar', 'none', ...
				'Toolbar', 'none' ...
			);
		end
	end
	
end

