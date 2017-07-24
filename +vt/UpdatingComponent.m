classdef (Abstract) UpdatingComponent < vt.Component & vt.StateListener
	
	properties
	end
	
	methods
		[] = update(this, source, eventdata);
	end
	
end

