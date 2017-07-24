classdef HelpMenuItem < vt.MenuItem & vt.ActionDispatcherWithoutData
	events
		HELP
	end
	
	methods
		function this = HelpMenuItem(parent, label)
			this@vt.MenuItem(parent, label);
			
			this.setCallback();
		end
	end
	
end

