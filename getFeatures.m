
function [ features ] = getFeatures(pathOut, imgfile, img, rset, featkind, measures, mode)
   
    [w,h,z] = size(img);     
    features =[];
    parameters.z=z;
    parameters.measures=measures;   
    
    features=[];
    for r=1:length(rset)
        file = [pathOut, '/img features/', imgfile, ' r_', num2str(rset(r)), '.mat'];
        if exist(file)==0
%             [full, within, between] = CNdirected_modelling_noborder(img, rset(r)); 
            [full, within, between] = CNdirectedRGB_GOD(img, rset(r));            

            parameters.r=rset(r);
            
            [w,h,z] = size(img);            
%             w=w-(rset(r)*2);
%             h=h-(rset(r)*2);
            
            degreeR = [getMeasures(full(1,1:w*h), parameters, z); getMeasures(full(2,1:w*h), parameters, z); getMeasures(within(1,1:w*h), parameters, 1);getMeasures(within(2,1:w*h), parameters, 1); getMeasures(between(1,1:w*h), parameters, z-1); getMeasures( between(2,1:w*h), parameters, z-1)];
            degreeG = [getMeasures(full(1,w*h+1: w*h*2), parameters, z); getMeasures(full(2,w*h+1: w*h*2), parameters,z); getMeasures(within(1,w*h+1: w*h*2), parameters,1);getMeasures(within(2,w*h+1: w*h*2), parameters,1); getMeasures(between(1,w*h+1: w*h*2), parameters, z-1); getMeasures( between(2,w*h+1: w*h*2), parameters, z-1)];
            degreeB = [getMeasures(full(1,w*h*2+1: w*h*3), parameters, z); getMeasures(full(2,w*h*2+1: w*h*3), parameters,z); getMeasures(within(1,w*h*2+1: w*h*3), parameters,1);getMeasures(within(2,w*h*2+1: w*h*3), parameters,1); getMeasures(between(1,w*h*2+1: w*h*3), parameters, z-1); getMeasures( between(2,w*h*2+1: w*h*3), parameters, z-1)];
            
            
            strengthR = [getMeasures(full(3,1:w*h), parameters, z); getMeasures(full(4,1:w*h), parameters, z); getMeasures(within(3,1:w*h), parameters, 1);getMeasures(within(4,1:w*h), parameters, 1); getMeasures(between(3,1:w*h), parameters, z-1); getMeasures( between(4,1:w*h), parameters,z-1)];
            strengthG = [getMeasures(full(3,w*h+1: w*h*2), parameters, z); getMeasures(full(4,w*h+1: w*h*2), parameters, z); getMeasures(within(3,w*h+1: w*h*2), parameters, 1);getMeasures(within(4,w*h+1: w*h*2), parameters,1); getMeasures(between(3,w*h+1: w*h*2), parameters,z-1); getMeasures( between(4,w*h+1: w*h*2), parameters,z-1)];
            strengthB = [getMeasures(full(3,w*h*2+1: w*h*3), parameters, z); getMeasures(full(4,w*h*2+1: w*h*3), parameters, z); getMeasures(within(3,w*h*2+1: w*h*3), parameters, 1);getMeasures(within(4,w*h*2+1: w*h*3), parameters,1); getMeasures(between(3,w*h*2+1: w*h*3), parameters,z-1); getMeasures( between(4,w*h*2+1: w*h*3), parameters,z-1)];

%             degreeALLfeatures = [getMeasures(full(1,:), parameters); getMeasures(full(2,:), parameters); getMeasures(within(1,:), parameters);getMeasures(within(2,:), parameters); getMeasures(between(1,:), parameters); getMeasures( between(2,:), parameters)];
%             strengthALLfeatures = [getMeasures(full(3,:), parameters); getMeasures(within(3,:), parameters); getMeasures(between(3,:), parameters)];
           
            
            degreeALLfeatures = [degreeR, degreeG, degreeB];
            strengthALLfeatures = [strengthR, strengthG, strengthB];
            
            save(file, 'degreeALLfeatures', 'strengthALLfeatures');   
        else
            load(file, 'degreeALLfeatures', 'strengthALLfeatures');  
        end
        
        
        [~, featSize] = size(degreeALLfeatures);
        
        
        switch mode
            case 'FULL'
                degreeALLfeatures = degreeALLfeatures(1, :);
                strengthALLfeatures = reshape(strengthALLfeatures(1:2, :), [1, featSize*2]);
            case 'WITHIN'
                degreeALLfeatures = degreeALLfeatures(3, :);
                strengthALLfeatures = reshape(strengthALLfeatures(3:4, :), [1, featSize*2]);
            case 'BETWEEN'
                degreeALLfeatures = degreeALLfeatures(5, :);
                strengthALLfeatures = reshape(strengthALLfeatures(5:6, :), [1, featSize*2]);
            case 'W+B'
                degreeALLfeatures = [degreeALLfeatures(3, :), degreeALLfeatures(5, :)];
                strengthALLfeatures = reshape(strengthALLfeatures(3:6, :), [1, featSize*4]);
            case 'ALL'
                degreeALLfeatures= [degreeALLfeatures(1, :), degreeALLfeatures(3, :), degreeALLfeatures(5, :)];
                strengthALLfeatures= reshape(strengthALLfeatures, [1, featSize*6]);
        end
        
        
        switch featkind
            case 'degree'                
                features = [features, degreeALLfeatures];
            case 'strength'
                features = [features, strengthALLfeatures];
            case 'degree+strength'
                features = [features, degreeALLfeatures, strengthALLfeatures];
        end
    end
end


