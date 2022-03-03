classdef Gesture < gs.GestureInterface
    
    methods
        function obj = Gesture(regions, phone_ID)
            if nargin ~= 0
                nGests = length(regions);
                obj(nGests,1) = obj;
                for iObj = 1:nGests
                    obj(iObj).local_ID = iObj;
                    obj(iObj).region = regions(iObj);
                    obj(iObj).articulator = regions(iObj).name;
                    obj(iObj).phone_ID = phone_ID;
                end
            end
        end
        
        function obj = setup(obj, k, config)
            for iObj = 1:length(obj)
                s = obj(iObj).region.timeseries;
                if obj(iObj).region.type == "Centroid"
                    s = obj(iObj).region.smooth_timeseries;
                end

                % velocity (from s) can be tangential, so send in the x- and y-
                % values of centroid
                % -- this should happen by default from vt.Action.findTimeseries()
                % - IS IT USING TANGENTIAL OR JUST ONE DIMENSION?
                
    %             [g,v] = DelimitGest(s, k);
    %             [g,v] = DelimitGest(s, k, [], 'USEFV', 'T');
    
                onsThr = config.delimitGest.onsThr;
                offsThr = config.delimitGest.offsThr;
                thrGons = config.delimitGest.thrGons;
                thrNons = config.delimitGest.thrNons;
                thrNoff = config.delimitGest.thrNoff;
                thrGoff = config.delimitGest.thrGoff;

                ht = config.delimitGest.ht;
                [g, v] = DelimitGest(s, k, ht, ...
                                        'ONSTHR', onsThr, 'OFFSTHR', offsThr, ...
                                        'THRGONS', thrGons, 'THRNONS', thrNons, ...
                                        'THRNOFF', thrNoff, 'THRGOFF', thrGoff ...
                                       );

                if isempty(g)
                    obj(iObj).COMMENT = "Automatic gesture-finding failed";
                else
                    obj(iObj).COMMENT = "Automatic gesture-finding succeeded";

                    obj(iObj).GONS = g.GONS;
                    obj(iObj).PVEL = g.PVEL;
                    obj(iObj).NONS = g.NONS;
                    obj(iObj).MAXC = g.MAXC;
                    obj(iObj).NOFFS = g.NOFFS;
                    obj(iObj).PVEL2 = g.PVEL2;
                    obj(iObj).GOFFS = g.GOFFS;
                    obj(iObj).PV = g.PV;
                    obj(iObj).PV2 = g.PV2;
                    obj(iObj).PD = g.PD;
                end
            end
        end
    end
end