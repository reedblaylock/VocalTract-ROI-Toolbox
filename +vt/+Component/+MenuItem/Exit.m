classdef Exit < vt.Component.MenuItem & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.CloseGui
	end
	
	methods
		function this = Exit(parent, label)
			this@vt.Component.MenuItem(parent, label);
			
			this.setCallback();
		end
	end
	
end

