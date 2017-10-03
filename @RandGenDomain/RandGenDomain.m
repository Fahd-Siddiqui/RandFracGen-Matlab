classdef RandGenDomain < handle
    %DOMAIN Class
    
    properties
        loc
        locR
        Fn
        Frac=RandGenFracture;
        Nf
    end
    
    methods
        %% Function to create elements from a given Coordinate Matrix
        function CreateFractureElements(Dom, B)
            
            Dom.Nf=size(B,1);
            
            for i=1:size(B,1)
                Dom.Frac(i,1)=RandGenFracture;
            end
            
            for i=1:size(B,1)
                Dom.Frac(i,1).loc(1,:)=B(i,:);
                if B(i,2)<B(i,4)
                    for j=2:B(i,4)-B(i,2)
                        Dom.Frac(i,1).loc(j-1,3:4)=[Dom.Frac(i,1).loc(j-1,1),Dom.Frac(i,1).loc(j-1,2)+1];
                        Dom.Frac(i,1).loc(j,1:2)=Dom.Frac(i,1).loc(j-1,3:4);
                    end
                end
                Dom.Frac(i,1).loc(end,3:4)=B(i,3:4);
                Dom.Frac(i,1).Ne=size(Dom.Frac(i,1).loc,1);
                Dom.Frac(i,1).Fn=i;
            end
            
            
            
        end
        %% Function to generate a location matrix from unrotate matrix
        function [location]=GenerateInputLocation(Dom)
            Dom.loc=[];
            
            Dom.Fn=[];
            for i=1:Dom.Nf
                Dom.loc=[Dom.loc;Dom.Frac(i).loc];
                Dom.Fn=[Dom.Fn;ones(Dom.Frac(i).Ne,1)*Dom.Frac(i).Fn];
            end
            location=[Dom.loc,Dom.Fn];
            
        end
        %% Function to generate rotated location matrix (Final form)
        function [locationR]=GenerateInputLocationR(Dom)
            
            Dom.locR=[];
            Dom.Fn=[];
            for i=1:Dom.Nf
                Dom.locR=[Dom.locR;Dom.Frac(i).locR];
                Dom.Fn=[Dom.Fn;ones(Dom.Frac(i).Ne,1)*Dom.Frac(i).Fn];
            end
            locationR=[Dom.locR,Dom.Fn];
        end
        
        
    end
    
end

