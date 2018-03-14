% This class would be a singleton class, if I weren't so afraid of MATLAB
% singletons (they've given me some performance/memory/scary problems).

classdef Factory < vt.Root
	properties
		actions
	end
	
	methods
		function this = Factory(reducer)
			% Instantiate an instance of every vt.Action
			[pathToActions, ~, ~] = fileparts(mfilename('fullfile'));
			files = dir(pathToActions);
			exclude = {'Dispatcher', 'Factory'};
			
			this.actions = struct();
			
			for iFile = 1:numel(files)
				actionFile = files(iFile).name;
				[~, actionName, ~] = fileparts(actionFile);
				
				if exist(['vt.Action' actionName], 'class') == 8 ...
						&& ~sum(strcmp(actionName, exclude))
					action = vt.Action.(actionName);
				
					% Register each vt.Action to the reducer
					reducer.register(action);

					% Save each vt.Action to the structure this.actions
					this.actions.(action.getName()) = action;
				end
			end
		end
		
		function action = get(actionName)
			action = this.actions.(actionName);
		end
	end
end