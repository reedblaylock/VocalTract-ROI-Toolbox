classdef Grid < vt.Component.Layout
	methods
		function this = Grid(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
		
		% perfunctory comment
		function [] = setParameters(this, varargin)
			p = vt.InputParser;
			p.KeepUnmatched = true;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout'));
			parse(p, this, varargin{:});
			
			s = p.Unmatched;
			
			if( this.isOldMatlabVersion() )
				% Change Widths to Sizes
				nameToChange = 'Widths';
				nameReplacement = 'ColumnSizes';
				s = this.renameField(s, nameToChange, nameReplacement);
				
				% Change MinimumWidths to MinimumSizes
				nameToChange = 'Heights';
				nameReplacement = 'RowSizes';
				s = this.renameField(s, nameToChange, nameReplacement);
				
				% Change Contents to Children
				nameToChange = 'Contents';
				nameReplacement = 'Children';
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
			
% 			this.handle = uiextras.Grid( ...
% 				'Parent', p.Results.parent.handle ...
% 			);
			if ( this.isOldMatlabVersion() )
				this.handle = uiextras.Grid( ...
					'Parent', p.Results.parent.handle ...
				);
			else
				this.handle = uix.Grid( ...
					'Parent', p.Results.parent.handle ...
				);
			end
		end
	end
end

