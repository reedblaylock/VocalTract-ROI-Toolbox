% This is the descriptive text for making midlines.
classdef Midline < vt.Component.Text & vt.State.Listener
	methods
		
		%%%%% CONSTRUCTOR %%%%%
		
		% Call the parent constructor (a text object), and apply certain
		% parameters.
		function this = Midline(parent)
			this@vt.Component.Text(parent);
			
			this.setParameters( ...
				'String', '', ...
				'FontSize', 12, ...
				'HorizontalAlignment', 'left' ...
			);
		end
		
		%%%%% STATE LISTENER %%%%%
		function [] = onIsEditingChange(this, state)
			% If the midline isn't being changed, erase whatever text is
			% currently active, then return
			if(~strfind(state.isEditing, 'midline'))
				string = get(this.handle, 'String');
				if(~isempty(string))
					this.setParameters('String', '');
				end
				return;
			end
			
			switch state.isEditing
				case 'midlineNew'
					string = 'Select the brightest pixel near each of the following landmarks (in order): 1. the front of the upper lip; 2. the tongue body; 3. the larynx.';
				case 'midlineEdit'
					string = 'Add points to the midline by clicking on the video. Remove a point from the midline by clicking that point.';
				otherwise
					string = '';
			end
			
			this.setParameters('String', string);
		end
		
		%%%%% OTHER %%%%%
		
		% Update the text and color of the midline text.
		function [] = update(this, string)
			this.setParameters( ...
				'String', string ...
			);
		end
	end
	
end

