classdef TextGridInterface
    
    properties
        tg
    end
    
    methods
        
        function obj = TextGridInterface(fname_textgrid)
            obj.tg = tgRead(fname_textgrid);
        end
        
        function [textgrid_labels, textgrid_label_times] = getLabelsFromTier(obj, tiername)
            tier_idx = tgI(obj.tg, tiername);
            textgrid_labels = [];
            textgrid_label_times = [];
            
            if tgIsPointTier(obj.tg, tier_idx)
                numPoints = tgGetNumberOfPoints(obj.tg, 1);
                textgrid_labels = repmat("", numPoints, 1);
                textgrid_label_times = NaN(numPoints, 1);
                i = 1;
                for labelx = obj.tg.tier{tgI(obj.tg, tiername)}.Label
                    textgrid_labels(i) = string(labelx);
                    textgrid_label_times(i) = obj.tg.tier{tgI(obj.tg, tiername)}.T(i);
                    i = i + 1;
                end
            elseif tgIsIntervalTier(obj.tg, tier_idx)
                numIntervals = tgGetNumberOfIntervals(obj.tg, 1);
                textgrid_labels = repmat("", numIntervals, 1);
                textgrid_label_times = NaN(numIntervals, 1);
                i = 1;
                for labelx = obj.tg.tier{tgI(obj.tg, tiername)}.Label
                    textgrid_labels(i) = string(labelx);
                    textgrid_label_times(i) = obj.tg.tier{tgI(obj.tg, tiername)}.T2(i) - obj.tg.tier{tgI(obj.tg, tiername)}.T1(i);
                    i = i + 1;
                end
            end
        end
        
        % Take off the beginning part of the TextGrid that has sounds in
        % isolation (so that you can just look at the beats) by cutting the
        % TextGrid according to the information from your textgrid_cuts.csv
        % list.
        function obj = trimStart(obj, start_cut_time)
            obj.tg = tgCut(obj.tg, start_cut_time, tgGetTotalDuration(obj.tg));
        end
        
        function obj = trim(obj, start_cut_time, end_cut_time)
            obj.tg = tgCut(obj.tg, start_cut_time, end_cut_time);
        end
    end
end