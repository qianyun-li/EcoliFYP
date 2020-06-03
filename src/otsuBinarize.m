function imgSeg = otsuBinarize(img)
    x = 0:5:255;
    [f,~] = ksdensity(img(:),x);
    [num, loc] = findpeaks(f,x);
    imgSeg = img;
    imgSeg(imgSeg==0) = loc(1);
    level = graythresh(imgSeg);
    imgSeg = imbinarize(imgSeg,level);
end