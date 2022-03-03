classdef Config
    properties
        basepath
        basename
        fname
        phoneTier
        use_smooth_timeseries
        label_info_table
        
        start_cut_time
        end_cut_time
        
        plot
        
        delimitGest
    end
    
    methods
        function obj = Config(configSettings)
            obj.basepath = configSettings.basepath;
            obj.basename = configSettings.basename;
            obj.fname = obj.createFileNames(configSettings);
            obj.phoneTier = configSettings.phoneTier;
            obj.use_smooth_timeseries = configSettings.use_smooth_timeseries;
            
            obj.label_info_table = obj.loadLabelInfoTable(obj.fname.label_info_table);
            [start_cut_time, end_cut_time] = obj.loadTextgridCuts(obj.fname.textgrid_cuts);
            obj.start_cut_time = start_cut_time;
            obj.end_cut_time = end_cut_time;

            obj.plot = configSettings.plot;
            obj.delimitGest = configSettings.delimitGest;
        end
        
        function label_info_table = loadLabelInfoTable(obj, fname_label_info_table)
            label_info_table = readtable(fname_label_info_table);
            label_info_table.label = string(label_info_table.label);
            label_info_table.name = string(label_info_table.name);
            label_info_table.primary_constriction = string(label_info_table.primary_constriction);
            label_info_table.manner_of_articulation = string(label_info_table.manner_of_articulation);
            label_info_table.articulators = string(label_info_table.articulators);
            label_info_table.split_type = string(label_info_table.split_type);
        end
        
        function [start_cut_time, end_cut_time] = loadTextgridCuts(obj, fname_textgrid_cuts)
            textgrid_cuts = readtable(fname_textgrid_cuts);
            textgrid_cuts.basename = string(textgrid_cuts.basename);
            
            start_cut_time = textgrid_cuts.start_cut_time(ismember(textgrid_cuts.basename, obj.basename));
            end_cut_time = textgrid_cuts.end_cut_time(ismember(textgrid_cuts.basename, obj.basename));
        end
        
        function fname = createFileNames(obj, config)
%           Create the filenames for all files associated with this File
            fname = struct();
            fname.wav         = fullfile(obj.basepath, config.wav_folder,         [config.basename '.wav']);
            fname.textgrid    = fullfile(obj.basepath, config.textgrid_folder,    [config.basename '.TextGrid']);
            fname.avi         = fullfile(obj.basepath, config.avi_folder,         [config.basename '.avi']);
            fname.manual_gest = fullfile(obj.basepath, config.manual_gest_folder, [config.basename '.lab']);
            fname.regions     = fullfile(obj.basepath, config.regions_folder,     [config.basename '_regions.mat']);
%             fname.drumtab     = fullfile(config.basepath, config.drumtab_folder,     [basename '.txt']);
            fname.label_info_table = fullfile(obj.basepath, config.gestural_scores_folder, 'sounds.csv');
            fname.textgrid_cuts = fullfile(obj.basepath, config.gestural_scores_folder, 'textgrid_cuts.csv');
            fname.image_out_folder = fullfile(obj.basepath, config.image_out_folder);

            if ~exist(fname.wav, 'file')
                disp(['Sound file not found at ' fname.wav '.']);
            end

            if ~exist(fname.textgrid, 'file')
                disp(['Textgrid file not found at ' fname.textgrid '.']);
            end

            if ~exist(fname.avi, 'file')
                disp(['Video file not found at ' fname.avi '.']);
            end
            
            if ~exist(fname.manual_gest, 'file')
                disp(['Manual corrections for gestures file not found at ' fname.manual_gest '.']);
            end

            if ~exist(fname.regions, 'file')
                disp(['Regions file not found at ' fname.regions '.']);
                
                fname.regions = fullfile(obj.basepath, config.regions_folder, config.default_regions_file);
                disp(['Loading default regions from ' fname.regions '.']);
                if ~exist(fname.regions, 'file')
                    disp(['Regions file not found at ' fname.regions '.']);
                end
            end

%             if ~exist(fname.drumtab, 'file')
%                 disp(['Drumtab file not found at ' fname.drumtab '.']);
%             end

            if ~exist(fname.label_info_table, 'file')
                disp(['Label info table not found at ' fname.regions '.']);
            end
            
            if ~exist(fname.textgrid_cuts, 'file')
                disp(['Textgrid cuts not found at ' fname.regions '.']);
            end
        end
        
        function tf = manualGesturesExist(obj)
            tf = exist(obj.fname.manual_gest, 'file');
        end
        

    end
end