clc, clear;
% read image
img = rgb2gray(imread('image/testFrac1.png')); % for tophat
% img = imread('image/E.coli-1.jpg'); % for gamma
figure, imshow(img);


% % get the region within disk
% [center, radius] = diskSeg(img);
% roi = drawcircle('Center', center, 'Radius', radius);
% mask = createMask(roi);
% img(~mask) = 0;
% rect = [center(1)-radius, center(2)-radius, radius*2, radius*2];
% img = imcrop(img, rect);
% mask = ~(img == 0);
% figure,imshow(img);
% img_ = preprocess(img, mask);
% imshow(img);
% nOL = 3;
% tVote = 0.4;
% [ballotBox1,ballotBox2] = vote(img_,[50,50],nOL,mask);
% imgSeg1 = false(size(ballotBox1)); imgSeg2 = imgSeg1;
% imgSeg1(ballotBox1 >= tVote * nOL^2) = 1;
% imgSeg2(ballotBox2 >= tVote * nOL^2) = 1;
% imgSeg = imgSeg1 & imgSeg2;
% % std_im = stdfilt(img_);
% % featureSet = cat(3, img_, std_im);
% % imgSeg = imsegkmeans(img_, 3);
% figure, imshow(imgSeg);

% top hat filtering
se = strel('disk',90);
img = imtophat(img, se);
% denoising
img_ = wiener2(img, [8 8]);
% gaussian filter
img_ = imgaussfilt(img_,0.75);
% % open operation
% SE = strel('disk',7);
% img_ = imopen(img_,SE);
% increase contrast
img_ = adapthisteq(img_);
figure, imshow(img_);

std_im = stdfilt(img_);
featureSet = cat(3, img_, std_im);
imgSeg = imsegkmeans(featureSet, 4);
figure, imshow(imgSeg,[]);
