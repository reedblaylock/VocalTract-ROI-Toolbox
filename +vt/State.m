classdef (Sealed) State < handle
	properties (AbortSet = true, SetAccess = ?vt.State.Setter)
		state = struct();
	end
	
	properties
		oldStateArray = {};
	end
	
	events
		StateChange
	end
	
	methods
		function set.state(obj, newState)
			oldState = obj.state;
			obj.state = newState;
			
			% Save the old state for un-do purposes
			obj.oldStateArray{end+1} = oldState;
			
			% Notify all listeners about the new state
			fields = fieldnames(obj.state);
			eventdata = vt.EventData(struct('state', obj.state));
			for iField = 1:numel(fields)
				if isfield(oldState, fields{iField}) ...
						&& ~isequal(obj.state.(fields{iField}), oldState.(fields{iField}))
					eventdata.data.propertyName = fields{iField};
					notify(obj, 'StateChange', eventdata);
				end
			end
		end
	end
end
