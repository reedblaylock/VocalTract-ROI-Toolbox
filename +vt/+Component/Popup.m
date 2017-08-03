classdef Popup < vt.Component
	methods
		function this = Popup(parent)
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
			this.handle = uicontrol( ...
				'Parent', p.Results.parent.handle, ...
				'Style', 'popup' ...
			);
		end
		
		% https://stackoverflow.com/questions/2760024/return-popupmenu-selection-in-matlab-using-one-line-of-code
		function str = getCurrentPopupString(this)
			list = this.getParameter('String');
			val = this.getParameter('Value');
			if iscell(list)
			   str = list{val};
			else
			   str = list(val,:);
			end
		end
	end
end

