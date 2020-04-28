clc;
clear;

global img center radius;
center = [];
radius = [];

imgOriginal = rgb2gray(imread('image/E.Coli-2.jpg'));
img = imgOriginal;

imshow(img); impixelinfo;
roi = drawcircle();
l = addlistener(roi,'ROIClicked',@roiEventHappend);
uiwait;
delete(l);

global mask;
mask = ~(img == 0);

w = 25;
img_filtered = img;
img_filtered(mask==0) = round(mean(img,'all'));
img_filtered = roifilt2(img_filtered,mask,@(x) ordfilt2(x,1,ones(w,w),'symmetric'));

img_filtered = roifilt2(img_filtered,mask,@(x) imfilter(x,ones(w,w)/(w*w),'symmetric'));

img = imsubtract(img,img_filtered);

img = roifilt2(img,mask,@(x) imadjust(x,stretchlim(x)));

img = imgaussfilt(img,0.75);
img = medfilt2(img);
% figure,imshow(img); impixelinfo;

SE = strel('disk',7);
img = imopen(img,SE);
nOL = 3;
tVote = 0.4;
imLabel = getLBPLables(img);
figure, imshow(imLabel,[]);

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

function imLabels = getLBPLables(img)
    featVec = getFeatVec(img, 1, [25 25]);
    imLabels = imsegkmeans(featVec,3);
end