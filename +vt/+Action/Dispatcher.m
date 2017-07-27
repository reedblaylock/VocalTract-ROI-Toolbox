% An Action.Dispatcher is responsible for dispatching some action at a time
% determined by the ActionDispatcher. For instance, a Button will dispatch an
% action whenever it is clicked.
% Action.Dispatchers all carry an instance of an Action.Factory that registers
% actions to some Listener.
classdef (Abstract) Dispatcher < vt.Root
	properties (Constant)
		actionFactory = vt.Action.Factory(vt.Action.Listener())
	end
	
	properties
		action
		data = []
	end
	
	properties (Abstract)
		actionType
	end
	
	methods
		function this = Dispatcher(varargin)
			p = inputParser;
			p.addOptional('data', []);
			parse(p, varargin{:});
			
			if(isempty(p.Results.data))
				actionData = this.data;
			else
				actionData = p.Results.data;
			end
			
			this.action = this.actionFactory.createAndRegisterAction( ...
				this.actionType, ...
				actionData ...
			);
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
		
		function [] = dispatchAction(this, varargin)
			p = inputParser;
			p.addRequired('this', @(this) isa(this, 'vt.Action.Dispatcher'));
			p.addOptional('data', []);
			parse(p, this, varargin{:});
			
			if(isempty(p.Results.data))
				this.action.dispatch(this.data);
			else
				this.action.dispatch(p.Results.data);
			end
		end
	end
end

