% read image
img = rgb2gray(imread('image/E.Coli-1.jpg')); % for tophat
% img = imread('image/E.coli-1.jpg'); % for gamma
figure, imshow(img);

% imdistline;

[center, radius] = diskSeg(img);
roi = drawcircle('Center', center, 'Radius', radius);
mask = createMask(roi);
img(~mask) = 0;
rect = [center(1)-radius, center(2)-radius, radius*2, radius*2];
img = imcrop(img, rect);
imshow(img);

% denoising
img_ = wiener2(img, [8 8]);
% gaussian filter
img_ = imgaussfilt(img_,0.75);
% % open operation
% SE = strel('disk',7);
% img_ = imopen(img_,SE);
% increase contrast
img_ = adapthisteq(img_);
imshow(img_);

[cs, rs] = imfindcircles(img_, [5,15], 'Sensitivity', 0.83);
viscircles(cs,rs);