classdef HButtonGroup < uix.HButtonBox & uix2.AButtonGroup
    %HButtonGroup - Extends uix.HButtonBox to create exclusive radio
    %   button groups.
    
    properties
        
    end
    
    methods
        function obj = HButtonGroup(varargin)
            %% Constructor
            %Superclass constructor 1
            obj = obj@uix.HButtonBox(varargin{:});
            %Superclass constructor 2
            obj = obj@uix2.AButtonGroup(varargin{:});
            
            obj.redraw();
            
        end
        
    end
    
    methods(Access = protected, Hidden = true)
        function onButtonStyleChanged(obj,src,evt) %#ok<INUSD>
            obj.redraw();
        end
                
    end
    
end

