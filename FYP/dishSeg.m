function [center,radius, rect] = dishSeg(img)
    img_s = imresize(img, 0.1);
    [sx, sy] = SobelEdgeOperator(img_s);
    mag =  sqrt(sx.^2 + sy.^2);
    grayImage = uint8(255 * mat2gray(mag));
    level = graythresh(grayImage);
    bw = imbinarize(grayImage,level);
    bw = imresize(bw,10);
    
    mask = imfill(bw, 'holes');
    mask = bwareaopen(mask, 10000);
    
    img(~mask) = 0;
    
    imgThresh = img;
    imgThresh(imgThresh > 0) = 1;
    projX = sum(imgThresh,1);
    projY = sum(imgThresh,2);
    % figure, plot(1:size(projX,2),projX); 
    % figure, plot(1:size(projY,1),projY); 
    
    petriXL = find(projX>0,1,'first'); 
    petriXR = find(projX>0,1,'last');  
    petriYU = find(projY>0,1,'first'); 
    petriYD = find(projY>0,1,'last');
    
    width = petriXR - petriXL;
    height = petriYD - petriYU;
    
    rect = [petriXL,petriYU,width,height];
%     imgCrop = imcrop(img, [petriXL,petriYU,width,height]);
    
    center = [fix((height+1)/2) fix((width+1)/2)];
    dishR = fix(min(height+1, width+1) / 2);
    radius = fix(dishR * 0.82);
end