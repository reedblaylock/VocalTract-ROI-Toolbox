classdef Action < vt.Root
	properties
		data
	end
	
	methods
% 		function this = Action(varargin)
% 			p = inputParser;
% 			p.addOptional('data', []);
% 			parse(p, varargin{:});
% 			
% 			this.data = p.Results.data;
% 		end
		
		function [] = dispatch(this, varargin)
			p = inputParser;
% 			p.addRequired('this', @(this) isa(this, 'vt.Action'));
			p.addOptional('data', '', @(data) validate(this, data));
			parse(p, varargin{:});
% 			parse(p, this, varargin{:});
			
			actionName = this.getName();
			if(isempty(p.Results.data))
				actionData = vt.EventData(this.data);
			else
				this.data = p.Results.data;
				actionData = vt.EventData(p.Results.data);
			end
			notify(this, actionName, actionData);
		end
		
		function tf = validate(this, data)
			tf = 1;
		end
		
		function actionName = getName(this)
			e = events(this);
			actionName = e{1};
			try
				assert(~strcmp(actionName, 'ObjectBeingDestroyed'))
				% Error: this class does not have an action specified
			catch excp
				this.log.exception(excp);
			end
		end
	end
	
end

