classdef Panel < uix.Panel
    %Panel - Adds Enable feature to uix.Panel
    %
    
    properties( Access = public, Dependent, AbortSet )
        Enable %Enable/Disable relevant children as expected
    end
    
    properties( Access = protected )
        Enable_ = 'on'; % backing for Enable
    end

    
    methods
        function obj = Panel( varargin )
            %Superclass
            obj@uix.Panel( varargin{:} );
            
        end
        
        function set.Enable(obj,sToggle)
            
            assert( isa( sToggle, 'char' ), 'uix2:InvalidPropertyValue', ...
                'Property ''Enable'' must be a string.' )
            assert( strcmpi(sToggle,'on') || strcmpi(sToggle,'off') , ...
                'uix2:InvalidPropertyValue', ...
                'Property ''Enable'' must be set to ''on'' or ''off''' )
            
            obj.Enable_ = sToggle;
            
            set( findall(obj, '-property', 'Enable'), 'Enable', sToggle);
            
            % Mark as dirty
%             obj.Dirty = true;
            
        end
        
        function sToggle = get.Enable(obj)
            
            sToggle = obj.Enable_;
                        
        end
        
    end
    
end

