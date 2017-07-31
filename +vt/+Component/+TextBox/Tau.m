classdef Tau < vt.Component.TextBox
	properties
		actionType = @vt.Action.ChangeTau;
	end
	
	methods
		function this = Tau(parent)
			p = vt.InputParser();
			p.addParent();
			p.parse(parent);
			
			this@vt.Component.TextBox(parent);
			this.setParameters('Enable', 'off');
			
% 			this.setCallback();
		end
	end
	
end