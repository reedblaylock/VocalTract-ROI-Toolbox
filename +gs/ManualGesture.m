classdef ManualGesture < gs.GestureInterface
    
    methods
        function obj = ManualGesture(fname_manual_gest, use_smooth_timeseries, regions, video_frameRate)%, regionIDs)
            if nargin ~= 0
                manual_gest_corrections_table = obj.loadManualCorrectionsTable(fname_manual_gest, video_frameRate);
                n = size(manual_gest_corrections_table, 1);
                obj(n,1) = obj;
                for iObj = 1:n
                    obj(iObj).articulator = manual_gest_corrections_table.articulator(iObj);
                    obj(iObj).GONS = manual_gest_corrections_table.GONS(iObj);
                    obj(iObj).PVEL = manual_gest_corrections_table.PVEL(iObj);
                    obj(iObj).NONS = manual_gest_corrections_table.NONS(iObj);
                    obj(iObj).MAXC = manual_gest_corrections_table.MAXC(iObj);
                    obj(iObj).NOFFS = manual_gest_corrections_table.NOFFS(iObj);
                    obj(iObj).PVEL2 = manual_gest_corrections_table.PVEL2(iObj);
                    obj(iObj).GOFFS = manual_gest_corrections_table.GOFFS(iObj);
                    obj(iObj).COMMENT = manual_gest_corrections_table.COMMENT(iObj);
                    obj(iObj).phone_ID = manual_gest_corrections_table.local_ID(iObj);

                    obj(iObj).region = regions.getRegionByArticulator(obj(iObj).articulator);
                    [pv, pv2, pd] = obj(iObj).findPeakVelocityAndDisplacement(use_smooth_timeseries, obj(iObj).region);%regions, regionIDs);

                    obj(iObj).PV = pv;
                    obj(iObj).PV2 = pv2;
                    obj(iObj).PD = pd;
                end
            end
        end
        
        function gestureObj = gs.Gesture(obj)
            gestureObj = gs.Gesture();
            gestureObj.articulator = obj.articulator;
            gestureObj.local_ID = obj.local_ID;
            gestureObj.GONS = obj.GONS;
            gestureObj.PVEL = obj.PVEL;
            gestureObj.NONS = obj.NONS;
            gestureObj.MAXC = obj.MAXC;
            gestureObj.NOFFS = obj.NOFFS;
            gestureObj.PVEL2 = obj.PVEL2;
            gestureObj.GOFFS = obj.GOFFS;
            gestureObj.PV = obj.PV;
            gestureObj.PV2 = obj.PV2;
            gestureObj.PD = obj.PD;
            gestureObj.COMMENT = obj.COMMENT;
            gestureObj.region = obj.region;
            gestureObj.phone_ID = obj.phone_ID;
        end
        
        function manual_gest_corrections_table = loadManualCorrectionsTable(obj, fname_manual_gest, video_frameRate)
            manual_gest_corrections_table = readtable(fname_manual_gest, 'FileType', 'text', 'Delimiter', '\t');
            
            manual_gest_corrections_table.articulator = string(manual_gest_corrections_table.articulator);
            manual_gest_corrections_table.COMMENT = string(manual_gest_corrections_table.COMMENT);

            manual_gest_corrections_table.GONS  = floor(manual_gest_corrections_table.GONS_ms_  * video_frameRate / 1000);
            manual_gest_corrections_table.PVEL  = floor(manual_gest_corrections_table.PVEL_ms_  * video_frameRate / 1000);
            manual_gest_corrections_table.NONS  = floor(manual_gest_corrections_table.NONS_ms_  * video_frameRate / 1000);
            manual_gest_corrections_table.MAXC  = floor(manual_gest_corrections_table.MAXC_ms_  * video_frameRate / 1000);
            manual_gest_corrections_table.NOFFS = floor(manual_gest_corrections_table.NOFFS_ms_ * video_frameRate / 1000);
            manual_gest_corrections_table.PVEL2 = floor(manual_gest_corrections_table.PVEL2_ms_ * video_frameRate / 1000);
            manual_gest_corrections_table.GOFFS = floor(manual_gest_corrections_table.GOFFS_ms_ * video_frameRate / 1000);
            
%             manual_gestures = ManualGesture(manual_gest_corrections_table, use_smooth_timeseries, obj.regions);%, regionIDs);
        end
        
        function [PV, PV2, PD] = findPeakVelocityAndDisplacement(obj, use_smooth_timeseries, region)%regions, regionIDs)
            % When you have s (the timeseries you got the gestures from) and
            % v (the velocity of the timeseries, as calculated in and returned 
            % by DelimitGest (along with g)), you can find these using:
            % - v(PVEL)
            % - v(PVEL2)
            % - sqrt(sum(diff([s(GONS,:);s(MAXC,:)]).^2))
            % (See DelimitGest for the context.)
            
            PV = [];
            PV2 = [];
            PD = [];

            if use_smooth_timeseries
                s = region.smooth_timeseries;
            else
                s = region.timeseries;
            end
            v = [diff(s(1:2,:)) ; s(3:end,:) - s(1:end-2,:) ; diff(s(end-1:end,:))] ./ 2;
            v = sqrt(sum(v.^2,2));

            PV = v(obj.PVEL);
            if isnan(obj.PVEL2)
                % This gesture is the result of a manual split so it doesn't
                % have a PVEL2 and might not have a MAXC
                PV2 = NaN;
            else
                PV2 = v(obj.PVEL2);
            end

            if isnan(obj.MAXC)
                % This gesture is the result of a manual split, in particular
                % the second half, so it doesn't have a MAXC
                PD = obj.calculate_peak_displacement(s, obj.GONS, obj.NONS);
            else
                PD = obj.calculate_peak_displacement(s, obj.GONS, obj.MAXC);
            end
        end
    end
end