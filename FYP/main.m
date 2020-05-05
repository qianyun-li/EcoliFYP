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
img = rgb2gray(imgOri);
figure("Name","Original Image"),imshow(img); impixelinfo;

% roi = drawcircle();
% l = addlistener(roi,'ROIClicked',@roiEventHappend);
% uiwait;
% delete(l);
[center, radius] = diskSeg(img);
roi = drawcircle('Center', center, 'Radius', radius);
mask = createMask(roi);
img(~mask) = 0;
rect = [center(1)-radius, center(2)-radius, radius*2, radius*2];
img = imcrop(img, rect);
imshow(img);

% top hat filtering
se = strel('disk',90);
img = imtophat(img, se);

img = preprocess(img);
% figure, imshow(img);

nOL = 3;
tVote = 0.4;

% [ballotBox1,ballotBox2] = vote(img,[50,50],nOL,mask);
% imgSeg1 = false(size(ballotBox1)); imgSeg2 = imgSeg1;
% imgSeg1(ballotBox1 >= tVote * nOL^2) = 1;
% imgSeg2(ballotBox2 >= tVote * nOL^2) = 1;
% imgSeg = imgSeg1&imgSeg2;
% figure('Name','Constant variance and mean'), imshow(imgSeg);

[ballotBox1,ballotBox2] = vote(img,[50,50],nOL);
imgSeg1 = false(size(ballotBox1)); imgSeg2 = imgSeg1;
imgSeg1(ballotBox1 >= tVote * nOL^2) = 1;
imgSeg2(ballotBox2 >= tVote * nOL^2) = 1;
imgSeg = imgSeg1 & imgSeg2;
figure('Name','Autothresholding'), imshow(imgSeg);

[numMin,numMax] = countCell(img, imgSeg);
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