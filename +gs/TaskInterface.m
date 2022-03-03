classdef TaskInterface < handle
    
    methods (Abstract)
        
        % Create tables, files, or whatever else is necessary for storing
        % the information that will be generated during work(). Store it in
        % data_table, probably.
        setup(obj)
        
        % Do something. Happens inside a loop created outside this class,
        % so all of this happens over a specific business object. In some
        % cases, the object might be a file and what's worked over is the
        % stuff inside the file. In other cases, it might be a single
        % gesture.
        work(obj)
        
        % Do something outside of a loop based on the data_table.
        cleanup(obj)
    end
end

