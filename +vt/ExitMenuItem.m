classdef ExitMenuItem < vt.MenuItem & vt.ActionDispatcherWithoutData
	events
		CLOSE_GUI
	end
	
	methods
		function this = ExitMenuItem(parent, label)
			this@vt.MenuItem(parent, label);
			
			this.setCallback();
		end
	end
	
end

