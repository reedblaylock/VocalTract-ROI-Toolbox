classdef AButtonGroup < handle
    %ARadioButtonGroup - Abstract for radio button group extensions to uix
    
    properties( Access = public, Dependent, AbortSet )
        Selection; %Index of the currently selected child
        ButtonStyle;
        Buttons; %List of button label strings- may be a cell array of strings or an mxn string array where each row is a label
        Enable;
    end
    
    properties
        SelectionChangeFcn = [];
    end
    
    properties(Dependent, Transient, SetAccess = protected)
        SelectedObject;  %HG2 handle of the currently selected object.
        ButtonHandles;
    end
    
    properties( Access = protected )
        Selection_ = [];
        ButtonStyle_ = 'Radio';
        g1GroupHandles = [];%handles of mutually exclusive uicontrols controlled by object
        Enable_ = 'on'; % backing for Enable
    end
    
    methods
        function obj = AButtonGroup(varargin)
            %% Constructor
        end
        
        %% Getters
        function iSelected = get.Selection(obj)
            iSelected = obj.Selection_;
        end
        
        function gSelection = get.SelectedObject(obj)
            if isempty(obj.Selection) || isempty(obj.g1GroupHandles)
                gSelection = [];
                return
            end
            gSelection = obj.g1GroupHandles(obj.Selection); %Reference Selection rather than Selection_ to enable validation??
        end
        
        function sStyle = get.ButtonStyle(obj)
            sStyle = obj.ButtonStyle_;
        end
        
        function ca1ButtonLabels = get.Buttons(obj)
            if isempty(obj.g1GroupHandles)
                ca1ButtonLabels = [];
                return
            end
            ca1ButtonLabels = obj.g1GroupHandles.String;
        end
        
        function g1GroupHandles = get.ButtonHandles(obj)
            g1GroupHandles = obj.g1GroupHandles;
        end
        
        function sToggle = get.Enable(obj)
            sToggle = obj.Enable_;
                        
        end
        
        %% Setters
        function set.ButtonStyle(obj,sStyle)
            assert( isa( sStyle, 'char' ) && ismember( lower( sStyle ), {'radio','toggle'} ), ...
                'uix2:InvalidPropertyValue', ...
                'Property ''ButtonStyle'' must be ''radio'' or ''toggle''.' )
            
            if ~isempty(obj.g1GroupHandles)
                obj.g1GroupHandles.Style = sStyle;
            end
            
            obj.ButtonStyle_ = [upper(sStyle(1)), lower(sStyle(2:end))];
            eventData = struct(...
                'Property', 'ButtonStyle', ...
                'Value', obj.ButtonStyle );
            obj.onButtonStyleChanged(obj,eventData);
            
        end
        
        function set.Selection(obj,iSelected)
            if isempty(iSelected)
                %Empty index
                if ~isempty(obj.g1GroupHandles)
                    for n=1:numel(obj.g1GroupHandles)
                        obj.g1GroupHandles(n).Value = 0;
                        %TODO: Enable??
                    end
                end
                if ~isempty(obj.Selection)
                    obj.Selection_ = [];
                end
                return
            end
            
            validateattributes(iSelected,{'numeric'},{'scalar','integer','positive'},'uix2.ARadioButtonGroup','Selection');
            
            %Do we have enough children?
            iNumButtons = numel(obj.g1GroupHandles);
            
            if iNumButtons < iSelected
                error('uix2:ARadioButtonGroup:InvalidSelection', ...
                    'Selection value %d exceeds number of children: %d',iSelected,iNumButtons);
            end
            
            i1Group = 1:iNumButtons;
            if ~isempty(i1Group) %Should always be true!
                i1Group(iSelected) = [];
                if ~isempty(i1Group)
                    for n=1:numel(i1Group)
                        obj.g1GroupHandles(i1Group(n)).Value = 0;
                        %TODO: Enable on?
                    end
                end
                obj.g1GroupHandles(iSelected).Value = 1;
                %TODO: Enable inactive?
                obj.Selection_ = iSelected;
            end
            
        end
        
        function set.Buttons(obj,caXButtonString)
            assert( isa( caXButtonString, 'char' ) || iscellstr( caXButtonString ) || isstruct( caXButtonString ), ...
                'uix2:InvalidPropertyValue', ...
                'Property ''Buttons'' must be a character array or a cell array of strings.' );
            
            if ischar(caXButtonString)
                cellstr(caXButtonString)
            end
            if ~isempty(obj.g1GroupHandles)
                delete(obj.g1GroupHandles(ishandle(obj.g1GroupHandles)));
            end
            for n = 1:numel(caXButtonString)
                uicontrol('Parent',obj,'Style',obj.ButtonStyle,...
                    'String',caXButtonString{n});
            end
            
            %TODO: get a nicer solution
            obj.g1GroupHandles = flipud(obj.Children);
            for n=1:numel(obj.g1GroupHandles)
                obj.g1GroupHandles(n).Callback = {@obj.onButtonPress};
            end
            
            obj.Selection = 1;%numel(obj.g1GroupHandles);
            
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
        
    end
    
    %% Callback Functions
    methods (Abstract = true, Access = protected, Hidden = true)
        onButtonStyleChanged(obj,source,eventdata);
    end
    
    methods (Access = protected, Hidden = true)
        function onButtonPress(obj,source,~)
            %Call the user-defined callback in SelectionChangeFcn()
            %event field names to be consistent with uibuttongroup
            
            [inList,idx] = ismember(source,obj.g1GroupHandles);
            
            if inList
                %Need to reference obj.g1GroupHandles
                % as otherwise obj.Children is the wrong way round!
                %TODO: get a nicer solution
                eventdata = struct('Source',obj.g1GroupHandles,...
                    'EventName','SelectionChanged',...
                    'OldValue',obj.Selection,...
                    'NewValue',idx);
                
                if idx == obj.Selection
                    %Same button selected - turn back on!
                    obj.g1GroupHandles(obj.Selection).Value = 1;
                    return
                end
                
                obj.Selection = idx;
                
                
                if ~isempty(obj.SelectionChangeFcn)
                    feval(obj.SelectionChangeFcn{1}, obj, eventdata);
                end
                
            end
            
        end
        
    end
    
end

