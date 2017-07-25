classdef (Abstract) Listener < handle
	properties
	end
	
	methods
		function method = action2method(~, underscoreAction)
			p = inputParser;
			p.addRequired('underscoreAction', @ischar);
			p.parse(underscoreAction);
			
			method = str2func(regexprep(lower(p.Results.underscoreAction), '_+(\w?)', '${upper($1)}'));
		end
		
		function method = property2method(~, propertyName)
			p = inputParser;
			p.addRequired('propertyName', @ischar);
			p.parse(propertyName);
			
			newName = ['update_' p.Results.propertyName ];
			method = str2func(regexprep(newName, '_+(\w?)', '${upper($1)}'));
		end
	end
	
end

