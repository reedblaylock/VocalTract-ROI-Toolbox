% An Action.Dispatcher is responsible for dispatching some action at a time
% determined by the ActionDispatcher. For instance, a Button will dispatch an
% action whenever it is clicked.
% Action.Dispatchers all carry an instance of an Action.Factory that registers
% actions to some Listener.
%
% There are three types of actions:
% 1. Actions that do not carry any data
% 2. Actions that carry a static piece of data
% 3. Actions that carry dynamic data
%
% You can account for each of these with vt.Action.Dispatcher.
% 1. Put the constructor handle for the appropriate action in this.actionType
% 2. Do #1. Call vt.Action.Dispatcher() in the constructor, and set
%    this.action.data = {the static data you want to send}.
% 3. Do #1. Overwrite vt.Action.Dispatcher/dispatchAction() to get, and validate
%    your data. Set this.action.data = {the data you want to send}, then do
%    this.action.dispatch().
classdef (Abstract) Dispatcher < vt.Root
% 	properties (Constant)
% 		actionFactory = vt.Action.Factory(vt.Action.Listener())
% 	end
	
	properties
		action
		data = []
	end
	
	properties (Abstract)
		actionType
	end
	
	methods
		function this = Dispatcher()
			this.action = this.actionType();
% 			actionFactory = vt.Action.Factory.getFactory();
% 			this.action = actionFactory.createAndRegisterAction( ...
% 				this.actionType ...
% 			);
		end
		
		function tf = isActionHandle(~, actionType)
			tf = false;
			if(isa(actionType, 'function_handle'))
				fcnStruct = functions(actionType);
				if(~isempty(strfind(fcnStruct.function, 'vt.Action')))
					tf = true;
				end
			end
		end
		
		function [] = dispatchAction(this, ~, ~)
			p = vt.InputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Action.Dispatcher'));
			parse(p, this);
% 			p.addOptional('data', []);
% 			parse(p, this, data);
			
			this.action.dispatch();
			
% 			if(isempty(p.Results.data))
% 				this.action.dispatch();
% 			else
% 				this.action.dispatch(p.Results.data);
% 			end
		end
	end
end

