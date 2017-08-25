classdef Grid < vt.Component.Layout
	methods
		function this = Grid(parent, varargin)
			this@vt.Component.Layout(parent, varargin{:});
		end
		
		function [] = setParameters(this, varargin)
			p = vt.InputParser;
			p.KeepUnmatched = true;
			p.addRequired('this', @(this) isa(this, 'vt.Component.Layout.Grid'));
			parse(p, this, varargin{:});
			
			params = fieldnames(p.Unmatched);
			
			if( this.isOldMatlabVersion() )
				% Change Heights to RowSizes
				nameToChange = 'Heights';
				nameReplacement = 'RowSizes';
				if( find(ismember(params, nameToChange)) )
					[p.Unmatched.(nameReplacement)] = p.Unmatched.(nameToChange);
					p.Unmatched = rmfield(p.Unmatched, nameToChange);
				end

				% Change Widths to ColumnSizes
				nameToChange = 'Widths';
				nameReplacement = 'ColumnSizes';
				if( find(ismember(params, nameToChange)) )
					[p.Unmatched.(nameReplacement)] = p.Unmatched.(nameToChange);
					p.Unmatched = rmfield(p.Unmatched, nameToChange);
				end
				
				% Change Contents to Children
				nameToChange = 'Contents';
				nameReplacement = 'Children';
				if( find(ismember(params, nameToChange)) )
					[p.Unmatched.(nameReplacement)] = p.Unmatched.(nameToChange);
					p.Unmatched = rmfield(p.Unmatched, nameToChange);
				end
			end

			setParameters@vt.Component.Layout(this, p.Unmatched(:));
		end
	end
	
	methods (Access = protected)
		function [] = construct(this, parent)
			p = vt.InputParser;
			p.addParent();
			parse(p, parent);
			
			this.handle = uiextras.Grid( ...
				'Parent', p.Results.parent.handle ...
			);
% 			if ( this.isOldMatlabVersion() )
% 				this.handle = guilayouttoolbox.old.layout.uiextras.Grid( ...
% 					'Parent', p.Results.parent.handle ...
% 				);
% 			else
% 				this.handle = guilayouttoolbox.new.layout.uix.Grid( ...
% 					'Parent', p.Results.parent.handle ...
% 				);
% 			end
		end
	end
end

