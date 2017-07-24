classdef LoadMenuItem < vt.MenuItem & vt.ActionDispatcherWithData
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
	events
		LOAD
	end
	
	methods
		% TODO: This is a good case for putting the parsing in a different
		% function. You'd want to have one function that puts all the additions
		% on p (so you can subclass it and put more additions on it) before
		% returning it and parsing it
		%
		% Although, I don't know how you parse it without all the data?
		%
		% ...
		%
		% I guess you can just pass all the paramters to the parsing function?
		function this = LoadMenuItem(parent, label, data)
			p = vt.InputParser;
			p.addParent();
			p.addRequired('label', @ischar);
			p.addRequired('data',  @ischar);
			parse(p, parent, label, data);
			
			this@vt.MenuItem(p.Results.parent, p.Results.label);
			
			this.setData(p.Results.data);
			
			this.setCallback();
		end
	end
	
end

