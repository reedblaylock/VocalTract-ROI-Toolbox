classdef Help < vt.Component.MenuItem & vt.Action.Dispatcher
	properties
		actionType = @vt.Action.Help
	end
	
	methods
		function this = Help(parent, label)
			this@vt.Component.MenuItem(parent, label);
			
			this.setCallback();
		end
	end
	
end

