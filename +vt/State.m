classdef (Sealed) State < handle
	% SetObservable emits PreSet and PostSet events.
	%
	% AbortSet will prevent the PostSet event from being emitted based on
	% isequal(). Non-static objects will not be considered equal, even if their
	% property values are identical.
	
	% https://www.mathworks.com/help/matlab/matlab_oop/validate-property-values.html
	
	% When a property is a struct, any change to a field of that property will
	% trigger a PostSet event for the property.
	% When a property is an object, changes to that object will not trigger a
	% PostSet event. In this case, a PostSet event is only triggered when a new
	% object (either a new instance or a new class) is assigned to the property.
	properties (SetObservable = true, AbortSet = true, SetAccess = ?vt.State.Setter)
		currentFrameNo
		video
		frameType = 'frame'
	end
end

