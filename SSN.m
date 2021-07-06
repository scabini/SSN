function [features] = SSN(image, rn)
%Main function to get SSN descriptors given a color or grayscale 'image' and a
%maximum radius 'rn' for pixel neighboring analysis

    L = 255; %pixel value range is [0,L], [0,255] stands for traditional 8-bit images. 
    %Change this for different kinds of images such as 16-bit ([0,65535]), or L=1 ([0,1]) if your images are binary or composed of normalized real values.
    [w,h,z] = size(image);
    if z ~= 3 && z~=1
        disp('Input image must be either a 3-channel color image (3d matrix), or a grayscale image (2d matrix)!!!');
        return;
    end     
    if min(min(min(image))) < 0
        disp('Input image must cointain only positive values!!!');  
        return;
    end
    if rn > 12
       disp('Maximum implemented radius is 12!!!')
       return;
    end    
    
    features=[];    
    rset = 1:1:rn;
    parameters.z=z;
    parameters.measures='all';
            
    switch z   
        case 3
            mode = 'W+B'; %kind of feature vector, 'W+B' is the recomended by the paper. Use 'ALL' to combine all networks (N+B+W)
            %As indicated in the paper, use 'ALL' with rn=4 for a faster
            %computation (performance similar to W+B with rn=6, but rn=6 covers a larger area of the image)
            switch mode
                case 'W+B'
                    for r=1:length(rset)
                        parameters.r=rset(r);
                        [~, within, between] = SSN_getFeatureMaps(double(image), rset(r), double(L));            

                        degreeR = [getMeasures(within(1,1:w*h), parameters, 1); getMeasures(between(1,1:w*h), parameters, z-1)];
                        degreeG = [getMeasures(within(1,w*h+1: w*h*2), parameters,1);getMeasures(between(1,w*h+1: w*h*2), parameters, z-1)];
                        degreeB = [getMeasures(within(1,w*h*2+1: w*h*3), parameters,1); getMeasures(between(1,w*h*2+1: w*h*3), parameters, z-1)];

                        strengthR = [getMeasures(within(3,1:w*h), parameters, 1);getMeasures(within(4,1:w*h), parameters, 1); getMeasures(between(3,1:w*h), parameters, z-1); getMeasures( between(4,1:w*h), parameters,z-1)];
                        strengthG = [getMeasures(within(3,w*h+1: w*h*2), parameters, 1);getMeasures(within(4,w*h+1: w*h*2), parameters,1); getMeasures(between(3,w*h+1: w*h*2), parameters,z-1); getMeasures( between(4,w*h+1: w*h*2), parameters,z-1)];
                        strengthB = [getMeasures(within(3,w*h*2+1: w*h*3), parameters, 1);getMeasures(within(4,w*h*2+1: w*h*3), parameters,1); getMeasures(between(3,w*h*2+1: w*h*3), parameters,z-1); getMeasures( between(4,w*h*2+1: w*h*3), parameters,z-1)];

                        degreeALLfeatures = [degreeR, degreeG, degreeB];
                        strengthALLfeatures = [strengthR, strengthG, strengthB];

                        [~, featSize] = size(degreeALLfeatures);

                        degreeALLfeatures = [degreeALLfeatures(1, :), degreeALLfeatures(2, :)];
                        strengthALLfeatures = reshape(strengthALLfeatures, [1, featSize*4]);

                        features = [features, degreeALLfeatures, strengthALLfeatures];

                    end
                case 'ALL'
                    for r=1:length(rset)
                        parameters.r=rset(r);
                        [full, within, between] = SSN_getFeatureMaps(double(image), rset(r), double(L));            

                        degreeR = [getMeasures(full(1,1:w*h), parameters, z); getMeasures(within(1,1:w*h), parameters, 1); getMeasures(between(1,1:w*h), parameters, z-1)];
                        degreeG = [getMeasures(full(1,w*h+1: w*h*2), parameters, z); getMeasures(within(1,w*h+1: w*h*2), parameters,1);getMeasures(between(1,w*h+1: w*h*2), parameters, z-1)];
                        degreeB = [getMeasures(full(1,w*h*2+1: w*h*3), parameters, z); getMeasures(within(1,w*h*2+1: w*h*3), parameters,1);getMeasures(between(1,w*h*2+1: w*h*3), parameters, z-1)];

                        strengthR = [getMeasures(full(3,1:w*h), parameters, z); getMeasures(full(4,1:w*h), parameters, z); getMeasures(within(3,1:w*h), parameters, 1);getMeasures(within(4,1:w*h), parameters, 1); getMeasures(between(3,1:w*h), parameters, z-1); getMeasures( between(4,1:w*h), parameters,z-1)];
                        strengthG = [getMeasures(full(3,w*h+1: w*h*2), parameters, z); getMeasures(full(4,w*h+1: w*h*2), parameters, z); getMeasures(within(3,w*h+1: w*h*2), parameters, 1);getMeasures(within(4,w*h+1: w*h*2), parameters,1); getMeasures(between(3,w*h+1: w*h*2), parameters,z-1); getMeasures( between(4,w*h+1: w*h*2), parameters,z-1)];
                        strengthB = [getMeasures(full(3,w*h*2+1: w*h*3), parameters, z); getMeasures(full(4,w*h*2+1: w*h*3), parameters, z); getMeasures(within(3,w*h*2+1: w*h*3), parameters, 1);getMeasures(within(4,w*h*2+1: w*h*3), parameters,1); getMeasures(between(3,w*h*2+1: w*h*3), parameters,z-1); getMeasures( between(4,w*h*2+1: w*h*3), parameters,z-1)];

                        degreeALLfeatures = [degreeR, degreeG, degreeB];
                        strengthALLfeatures = [strengthR, strengthG, strengthB];

                        [~, featSize] = size(degreeALLfeatures);

                        degreeALLfeatures= [degreeALLfeatures(1, :), degreeALLfeatures(2, :), degreeALLfeatures(3, :)];
                        strengthALLfeatures= reshape(strengthALLfeatures, [1, featSize*6]);

                        features = [features, degreeALLfeatures, strengthALLfeatures];

                    end
            end
            
        case 1
             for r=1:length(rset)
                parameters.r=rset(r);
                full = SSNgrey_getFeatureMaps(double(image), rset(r), double(L));            

                degreeR = getMeasures(full(1,1:w*h), parameters, z);

                strengthR = [getMeasures(full(3,1:w*h), parameters, z); getMeasures(full(4,1:w*h), parameters, z)];

                degreeALLfeatures = degreeR;
                strengthALLfeatures = strengthR;

                [~, featSize] = size(degreeALLfeatures);

                degreeALLfeatures= degreeALLfeatures(1, :);
                strengthALLfeatures= reshape(strengthALLfeatures, [1, featSize*2]);

                features = [features, degreeALLfeatures, strengthALLfeatures];

            end
    end
end


    


