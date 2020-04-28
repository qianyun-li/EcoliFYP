img = rgb2gray(imread('image/E.Coli-1.jpg'));
figure,imshow(img);
% img = rgb2gray(imread('image/E.Coli-2.jpg'));
% img = rgb2gray(imread('image/E.Coli+PtCo-1.jpg'));
% img = rgb2gray(imread('image/E.Coli+PtCo-1 small.jpg'));
% img = rgb2gray(imread('image/E.Coli+PtCo-2.jpg'));
% img = rgb2gray(imread('image/LB-1.jpg'));
% img = rgb2gray(imread('image/LB-2.jpg'));
% img = rgb2gray(imread('image/LB+PtCo-1.jpg'));
% img = rgb2gray(imread('image/LB+PtCo-2.jpg'));
% img = uint8(ones(size(img))*255) - img;

% tophat filtering
se = strel('disk',90);
img_ = imtophat(img, se);
imshow(img_);

[sx, sy] = SobelEdgeOperator(img_);
mag =  sqrt(sx.^2 + sy.^2);
grayImage = uint8(255 * mat2gray(mag));
level = graythresh(grayImage);
bw = imbinarize(grayImage,level);

mask = imfill(bw, 'holes');
mask = bwareaopen(mask, 2000);

img_(~mask) = 0;

imgThresh = img_;
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

imgCrop = imcrop(img_, [petriXL,petriYU,width, height]);
imshow(imgCrop);

center = [fix((height+1)/2) fix((width+1)/2)];
dishR = fix(min(height+1, width+1) / 2);
ROIR = fix(dishR * 0.82);

roi = drawcircle('Center', center, 'Radius', ROIR);
mask = createMask(roi);
imgCrop(~mask) = 0;
rect = [center(1)-ROIR, center(2)-ROIR, ROIR*2, ROIR*2];
ROI = imcrop(imgCrop, rect);
imshow(ROI);

% denoising
ROI = wiener2(ROI, [8 8]);
% gaussian filter
ROI = imgaussfilt(ROI,0.75);
% open operation
SE = strel('disk',7);
ROI = imopen(ROI,SE);
% increase contrast
ROI = adapthisteq(ROI);


[f,xi] = ksdensity(ROI(:), 0:1:256);
[~, loc] = findpeaks(f, 0:1:256);
level = (loc(2)+loc(3)) / 255 * 0.45; 
bw = imbinarize(ROI,level);
imshow(bw);

stats = regionprops(bw, 'basic');





