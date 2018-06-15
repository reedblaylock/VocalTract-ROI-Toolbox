classdef Panel < vt.Component.Layout
	methods
		function this = Panel(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
        end
        
        function [] = setParameters(this, varargin)
			p = inputParser;
			p.KeepUnmatched = true;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout'));
			parse(p, this, varargin{:});
			
			s = p.Unmatched;
			
			if vt.Config.isOldMatlabVersion()
                % Change Contents to Children
				nameToChange = 'Contents';
				nameReplacement = 'Children';
				s = this.renameField(s, nameToChange, nameReplacement);
				
				% Change Selection to SelectedChild
				nameToChange = 'Selection';
				nameReplacement = 'SelectedChild';
				s = this.renameField(s, nameToChange, nameReplacement);
			end
			
			c = this.struct2interleavedCell(s);
			setParameters@vt.Component.Layout(this, c{:});
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
% 			this.handle = uiextras.Panel( ...
% 				'Parent', p.Results.parent.handle ...
% 			);
			if vt.Config.isOldMatlabVersion()
				this.handle = uiextras.Panel( ...
					'Parent', p.Results.parent.handle ...
				);
			else
				this.handle = uix.Panel( ...
					'Parent', p.Results.parent.handle ...
				);
			end
		end
	end
end

