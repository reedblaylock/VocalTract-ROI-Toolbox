% The ActionFactory's job is to create actions, register those actions, and
% return those actions to the classes that want to emit them. The benefit of an
% ActionFactory is that actions are created and registered automatically in any
% Component that extends the ActionDispatcher class.
classdef Factory < vt.Root
	properties
		actionListener
	end
	
	methods
		function this = Factory(actionListener)
			p = inputParser;
			p.addRequired('actionListener', @(actionListener) isa(actionListener, 'vt.Action.Listener'));
			p.parse(actionListener);
			
			this.actionListener = p.Results.actionListener;
		end
		
		function action = createAndRegisterAction(this, actionType, data)
			action = this.createAction(actionType, data);
			this.registerAction(action);
		end
		
		function action = createAction(~, actionType, data)
% 			actionName = this.prepareActionName(actionName);
% 			action = vt.Action.(actionName)(data);
			action = actionType(data);
		end
		
		function [] = registerAction(this, action)
			this.actionListener.registerAction(action);
		end
		
		function actionName = prepareActionName(~, actionName)
			actionName = regexprep(lower(['_' actionName '_action']), '_+(\w?)', '${upper($1)}');
		end
	end
	
end

