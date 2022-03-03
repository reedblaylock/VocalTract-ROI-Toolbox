classdef Phone
    
    properties
        gestures % list of gestures
        label % arpabet or other representation of this Phone
        local_ID % position/order in its File's textgrid
        global_ID % ID of this Phone among all the Phones in this data collection
%         metrical_position % position of this Phone in the meter (e.g., beat 2) for this File
%         amplitude % how loud the Phone is
    end
    
    methods
        function obj = Phone(local_IDs)
            if nargin ~= 0
                nPhones = length(local_IDs);
                obj(nPhones,1) = obj;
                for iObj = 1:nPhones
                    obj(iObj).local_ID = local_IDs(iObj);
                end
            end
        end
        
        function obj = setup(obj, phone_labels, phone_samples, label_info_table, regions, config)
            for iPhone = 1:length(obj)
                phone_label = phone_labels(iPhone);
                phone_sample = phone_samples(iPhone);
                
                obj(iPhone).label = phone_label;

                % loop through all the articulators associated with this sound
                label_articulators = label_info_table.articulators(label_info_table.label(:)==phone_label);
                label_articulators = strtrim(split(string(label_articulators), ','));
                % (don't try to loop when there are no articulators)
                if label_articulators == ""
                    label_articulators = [];
                end
                
                % Get all the regions that match label_articulators
                gest_regions = regions(ismember([regions.name], label_articulators));

                obj(iPhone).gestures = gs.Gesture(gest_regions, obj(iPhone).local_ID);
                obj(iPhone).gestures = obj(iPhone).gestures.setup(phone_sample, config);
            end
        end
        
        function gif(obj, config, video, img)
            for iObj = 1:length(obj)
                gests = obj(iObj).gestures;
                start_frame = min([[gests.GONS], [gests.PVEL], [gests.NONS], [gests.MAXC], [gests.NOFFS], [gests.PVEL2], [gests.GOFFS]]);
                end_frame = max([[gests.GONS], [gests.PVEL], [gests.NONS], [gests.MAXC], [gests.NOFFS], [gests.PVEL2], [gests.GOFFS]]);
                img.gif(config.basename, config.fname.image_out_folder, obj(iObj).local_ID, obj(iObj).label, video, start_frame, end_frame);
            end
        end
    end
    
end