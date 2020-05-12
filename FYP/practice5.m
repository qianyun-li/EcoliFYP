% imgOri = imread('image/E.Coli-1.jpg');
% imgOri = imread('image/E.Coli-2.jpg');
imgOri = imread('image/E.Coli+PtCo-1.jpg');
% imgOri = imread('image/E.Coli+PtCo-2.jpg');
% imgOri = imread('image/LB-1.jpg');
% imgOri = imread('image/LB-2.jpg');
% imgOri = imread('image/LB+PtCo-1.jpg');
% imgOri = imread('image/LB+PtCo-2.jpg');
img = rgb2gray(imgOri);
figure("Name","Original Image"),imshow(img); impixelinfo;

se = strel('disk',90);
img = imtophat(img, se);

[center, radius] = diskSeg(img);
roi = drawcircle('Center', center, 'Radius', radius);
mask = createMask(roi);
img(~mask) = 0;
rect = [center(1)-radius, center(2)-radius, radius*2, radius*2];
img = imcrop(img, rect);
imshow(img);

img = preprocess(img);

bw = otsu(img);

figure, imshow(bw);
