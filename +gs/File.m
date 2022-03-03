classdef File
    
    properties
        phones % list of phones
        video % video data
        regions % regions data
        basename % base name of file, usually for display
        tg % textgrid data
        config
        
        start_cut_time % time at which this file should be considered to start (seconds)
        end_cut_time % time at which this file should be considered to end (seconds)
    end
    
    methods
%         function obj = File(basepath, basename, start_cut_time, end_cut_time)
        function obj = File(config)
            obj.basename = config.basename;
            obj.config = config;
            obj.start_cut_time = config.start_cut_time;
            obj.end_cut_time = config.end_cut_time;
        end
        
        function obj = work(obj, tg, video, regions, varargin)
            p = inputParser;
            p.addRequired('tg', @(x) isa(x, 'gs.TextGridInterface'));
            p.addRequired('video', @(x) isa(x, 'gs.Video'));
            p.addRequired('regions', @(x) isa(x, 'gs.Region'));
            p.addOptional('manualGestures', gs.ManualGesture.empty(0), @(x) isa(x, 'gs.ManualGesture'));
            parse(p, tg, video, regions, varargin{:});
            
            obj.tg = p.Results.tg;
            obj.video = p.Results.video;
            obj.regions = p.Results.regions;
            
            [textgrid_labels, textgrid_label_times] = obj.tg.getLabelsFromTier(obj.config.phoneTier);
            textgrid_label_samples = floor(textgrid_label_times * obj.video.frameRate) + 1;
            
%             meter_tier = tgI(obj.tg.tg, 'meter_all'); % = 'meter'; if you just want one sound per beat

            local_IDs = 1:length(textgrid_labels);
            obj.phones = gs.Phone(local_IDs);
            obj.phones = obj.phones.setup(textgrid_labels, textgrid_label_samples, obj.config.label_info_table, obj.regions, obj.config);
            
            if ~isempty(p.Results.manualGestures)
                obj = obj.applyManualGestures(p.Results.manualGestures);
            end
            
            obj = obj.applySplitGestures();

        end
        
        function obj = applyManualGestures(obj, manualGestures)
            p = inputParser;
            p.addRequired('manualGestures', @(x) isa(x, 'gs.ManualGesture'));
            parse(p, manualGestures);
            manualGestures = p.Results.manualGestures;
            
            % Replace the automatically-generated gestures with the
            % manually-corrected ones
            
            for iManualGest = 1:length(manualGestures)
                iPhone = find([obj.phones.local_ID] == manualGestures(iManualGest).phone_ID);
                iGest = find([obj.phones(iPhone).gestures.articulator] == manualGestures(iManualGest).articulator);
                manualGestures(iManualGest).local_ID = obj.phones(iPhone).gestures(iGest).local_ID;
                obj.phones(iPhone).gestures(iGest) = manualGestures(iManualGest);
            end
        end
        
        function obj = applySplitGestures(obj)
            % Split gestures
            % For each label,
            for iPhone = 1:(length(obj.phones)-1)
                thisPhone = obj.phones(iPhone);
                nextPhone = obj.phones(iPhone + 1);

                % if that label's split_type is "closure" and the next label's
                %   split_type is "release"...
                label_split_type1 = obj.config.label_info_table.split_type(obj.config.label_info_table.label == thisPhone.label);
                label_split_type2 = obj.config.label_info_table.split_type(obj.config.label_info_table.label == nextPhone.label);

                if ~(label_split_type1 == "closure" && label_split_type2 == "release")
                    continue;
                end

                % get the time series for the articulator(s) the labels share
                label_articulators1 = obj.config.label_info_table.articulators(obj.config.label_info_table.label == thisPhone.label);
                label_articulators1 = strtrim(split(string(label_articulators1), ','));
                label_articulators2 = obj.config.label_info_table.articulators(obj.config.label_info_table.label == nextPhone.label);
                label_articulators2 = strtrim(split(string(label_articulators2), ','));
                label_articulators = intersect(label_articulators1, label_articulators2);
                % (don't try to loop when there are no articulators)
                if label_articulators == ""
                    label_articulators = [];
                end

                % loop through all the articulators associated with this sound
                for iArticulator = 1:length(label_articulators)
                    region = obj.regions.getRegionByArticulator(label_articulators(iArticulator));

                    % s = the timeseries for that region
                    s = region.timeseries;
                    if region.type == "Centroid"
                        s = region.smooth_timeseries;
                    end

                    gest1 = thisPhone.gestures([thisPhone.gestures.articulator] == label_articulators(iArticulator));
                    gest2 = nextPhone.gestures([nextPhone.gestures.articulator] == label_articulators(iArticulator));

                    % split the gestures and receive the updated gest_table
                    [gest1, gest2] = obj.split_gest(gest1, gest2, s);
                    
                    obj.phones(iPhone).gestures([thisPhone.gestures.articulator] == label_articulators(iArticulator)) = gest1;
                    obj.phones(iPhone + 1).gestures([nextPhone.gestures.articulator] == label_articulators(iArticulator)) = gest2;
                end
            end
        end
        
        function [gest1, gest2] = split_gest(obj, gest1, gest2, s)
            % This function happens *after* manual corrections have already been
            % implemented. Manual corrections are usually just finding better gestures
            % in mviewRT, and maybe moving gesture landmarks a bit. It's expected that
            % the user won't have split gestures during manual correction, which is why
            % this function happens after manual corrections have been loaded. But, on
            % the off-chance that the user *did* split gestures already, we expect to
            % see some NaNs.

            if any(isnan([ ...
                    gest1.GONS,  gest2.GONS, ...
                    gest1.PVEL,  gest2.PVEL, ...
                    gest1.NONS,  gest2.NONS, ...
                    gest1.MAXC,  gest2.MAXC, ...
                    gest1.NOFFS, gest2.NOFFS, ...
                    gest1.PVEL2, gest2.PVEL2, ...
                    gest1.GOFFS, gest2.GOFFS, ...
                    gest1.PV,    gest2.PV, ...
                    gest1.PV2,   gest2.PV2, ...
                    gest1.PD,    gest2.PD ...
                    ]))
                disp('Gesture has NaNs, so it might already be split. Skipped.');
                return;
            end

            gest2.GONS = gest1.NOFFS;
            gest2.PVEL = gest1.PVEL2;
            gest2.NONS = gest1.GOFFS;
            gest2.PV = gest1.PV2;
            gest2.PD = gest2.calculate_peak_displacement(s, gest2.GONS, gest2.NONS);

            % gest_table.NOFFS(row_g1) = NaN; % closure gesture's NOFFS is release gesture's GONS
            gest1.PVEL2 = NaN;
            gest1.GOFFS = NaN;
            gest1.PV2 = NaN;

            gest2.MAXC = NaN;
            gest2.NOFFS = NaN;
            gest2.PVEL2 = NaN;
            gest2.GOFFS = NaN;
            gest2.PV2 = NaN;
        end
        
        function plot_url = plotly(obj, varargin)
            p = inputParser;
            p.addOptional('plot_title', obj.basename, @(x) ischar(x) || isstring(x));
            parse(p, varargin{:});
            plot_title = p.Results.plot_title;
            
            [textgrid_labels, textgrid_label_times] = obj.tg.getLabelsFromTier(obj.config.phoneTier);
            
            plotlyObj = gs.PlotlyTask();
            plot_url = plotlyObj.work(obj.config, obj.start_cut_time, obj.end_cut_time, obj.video.frameRate, vertcat(obj.phones.gestures), obj.regions, textgrid_labels, textgrid_label_times, plot_title);%, audio, fs_wav);%, textgrid_label_samples, meter_labels);
        end
        
        % Works on an array of File objects. Converts them to table
        % format.
        function tbl = table(objArray)
            w = warning('off','MATLAB:structOnObject'); % turn off warning
            
            gesttable = struct2table(arrayfun(@struct, vertcat(objArray.phones.gestures)));
            phonetable = struct2table(arrayfun(@struct, objArray.phones));
            phonetable = removevars(phonetable, {'gestures', 'global_ID'});
            tbl = join(gesttable, phonetable, 'leftkeys', 'phone_ID', 'rightkeys', 'local_ID');
            
            warning(w); % turn warning back on
        end
    end

    
end