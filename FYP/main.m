clc;
clear;

global img center radius;
center = [];
radius = [];

% imOri = imread('image/LB-1.jpg');
% tic
% img = im2uint8(rgb2gray(balanceLight1(imOri)));
% img = imadjust(img, [0.2 0.3]);
% figure, imshowpair(img, img_con, 'montage');
% toc

imgOri = imread('image/E.Coli-1.jpg');
% imgOri = imread('image/E.Coli-2.jpg');
% imgOri = imread('image/E.Coli+PtCo-1.jpg'); % 1 loc min
% imgOri = imread('image/E.Coli+PtCo-2.jpg'); 
% imgOri = imread('image/LB-1.jpg'); % 1 loc min
% imgOri = imread('image/LB-2.jpg'); 
% imgOri = imread('image/LB+PtCo-1.jpg'); % np
% imgOri = imread('image/LB+PtCo-2.jpg'); % np

img = rgb2gray(imgOri);
figure("Name","Original Image"),imshow(img); impixelinfo;

se = strel('disk',90);
img = imtophat(img, se);

% roi = drawcircle();
% l = addlistener(roi,'ROIClicked',@roiEventHappend);
% uiwait;
% delete(l);

[center, radius, rect] = dishSeg(img);
img = imcrop(img, rect);
imshow(img);

% [center, radius] = diskSeg(img);

roi = drawcircle('Center', center, 'Radius', radius);
mask = createMask(roi);
img(~mask) = 0;
rect = [center(1)-radius, center(2)-radius, radius*2, radius*2];
img = imcrop(img, rect);
imshow(img);

img = preprocess(img);
% figure, imshow(img);

blockSize = [50 50]; nOL = 3; tVote = 0.4;
imgSeg = kmeansCluster(img,blockSize, nOL,tVote);
figure('Name','Autothresholding'), imshow(imgSeg);

[numMin,numMax] = colonyCount(img, imgSeg);
disp(['The approximate number of cells is ', num2str(round(numMin)), ' to ',  num2str(round(numMax))]);

function roiEventHappend(src,evt)
    global img center radius;
    evname = evt.EventName;

    switch(evname)
        case{'ROIClicked'}
            if isequal(center,src.Center) && isequal(radius,src.Radius)
                mask = createMask(src);
                img(~mask) = 0;
                rect = [src.Center(1)-src.Radius, src.Center(2)-src.Radius, src.Radius*2, src.Radius*2];
                img = imcrop(img, rect);
                imshow(img); impixelinfo;
                clearvars -global center radius
                uiresume;
            else
                center = src.Center;
                radius = src.Radius;
            end
    end
end