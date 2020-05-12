clear; clc;

img = rgb2gray(imread('image/E.Coli-1.jpg'));
% img = rgb2gray(imread('image/E.Coli-2.jpg'));
% img = rgb2gray(imread('image/E.Coli+PtCo-1.jpg'));
% img = rgb2gray(imread('image/E.Coli+PtCo-1 small.jpg'));
% img = rgb2gray(imread('image/E.Coli+PtCo-2.jpg'));
% img = rgb2gray(imread('image/LB-1.jpg'));
% img = rgb2gray(imread('image/LB-2.jpg'));
% img = rgb2gray(imread('image/LB+PtCo-1.jpg'));
% img = rgb2gray(imread('image/LB+PtCo-2.jpg'));
% img = uint8(ones(size(img))*255) - img;
figure,imshow(img);

% tophat filtering
se = strel('disk',90);
img_ = imtophat(img, se);
imshow(img_);

img_s = imresize(img_, 0.1);
[sx, sy] = SobelEdgeOperator(img_s);
mag =  sqrt(sx.^2 + sy.^2);
grayImage = uint8(255 * mat2gray(mag));
level = graythresh(grayImage);
bw = imbinarize(grayImage,level);
bw = imresize(bw,10);

mask = imfill(bw, 'holes');
mask = bwareaopen(mask, 10000);

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
% rect = [center(1)-ROIR, center(2)-ROIR, ROIR*2, ROIR*2];
rect = [center(1)-ROIR, center(2)-ROIR, ROIR*2, ROIR*2];
ROI = imcrop(imgCrop, rect);
figure, imshow(ROI);

ROI = preprocess(ROI);

x = 0:5:255;
[f,~] = ksdensity(ROI(:),x);
[num, loc] = findpeaks(f,x);
ROI_ = ROI;
ROI_(ROI_==0) = loc(1);

level = graythresh(ROI_);
bw = imbinarize(ROI_,level);
figure,imshow(bw);





