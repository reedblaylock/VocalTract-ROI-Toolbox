classdef GestureInterface
    properties
        articulator
        local_ID
        GONS
        PVEL
        NONS
        MAXC
        NOFFS
        PVEL2
        GOFFS
        PV
        PV2
        PD
        COMMENT
        region
        phone_ID
    end
    
    methods (Sealed)
        function PD = calculate_peak_displacement(obj, s, d1, d2)
            PD = sqrt(sum(diff([s(d1,:);s(d2,:)]).^2));
        end
    end
        
end