% This class makes the menu items for loading files. You can pass any string
% you want as the data parameter, and a call will be made to vt.Reducer.load
% with the data you want representing the file signature (defined by you).
% For instance, passing 'avi' as the data parameter tells vt.Reducer to use
% the function that loads AVIs as opposed to VocalTract objects or something
% else.
%
% If you want to make your own loader, start by putting another one of these
% vt.LoadMenuItems in the menu bar, then put your implementation logic in
% vt.Reducer (and any classes it might need to work with).
	
classdef Load < vt.Component.MenuItem & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.Load
	end
	
	methods
		function this = Load(parent, label, data)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			p.addRequired('data',  @ischar);
			parse(p, parent, label, data);
			
			this@vt.Component.MenuItem(p.Results.parent, p.Results.label);
			
			this@vt.Action.Dispatcher();
			this.action.data = p.Results.data;
			
			this.setCallback();
		end
	end
	
end

