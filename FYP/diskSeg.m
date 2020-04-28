function [center, radius] = diskSeg(img)
scale = 200 / size(img,2);
img2 = imresize(img, scale);
w = size(img2,2);
[center, radius, ~] = imfindcircles(img2,[fix(w/4) ceil(w/2)],'Sensitivity', 0.99);
center = center(1,:) / scale;
radius = radius(1) / scale * 0.85;
end