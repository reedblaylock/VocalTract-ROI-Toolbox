classdef DeleteRegion < vt.Action
	events
		DELETE_REGION
	end
	
	properties
		id
	end
	
	methods
		function prepare(this, id)
			this.id = id;
		end

	end
end

