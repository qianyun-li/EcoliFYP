function img = preprocess(img, option)
    mask = ~(img == 0);
    
    if option(1) ~= 0
        % Even Illumination
        w = 25; img_filtered = img;
        img_filtered(mask==0) = round(sum(img,'all') / sum(mask,'all'));
        img_filtered = roifilt2(img_filtered,mask,@(x) ordfilt2(x,1,ones(w,w),'symmetric'));
        img_filtered = roifilt2(img_filtered,mask,@(x) imfilter(x,ones(w,w)/(w*w),'symmetric'));
        img = imsubtract(img,img_filtered);
        img = roifilt2(img,mask,@(x) imadjust(x,stretchlim(x)));
    end

    if option(2) ~= 0
        img = imgaussfilt(img,0.75);
    end
    
    if option(3) ~= 0
        % Enhance Contrast
        img = imadjust(img);
    end
    
    if option(4) ~= 0
        SE = strel('disk',7);
        img = imopen(img,SE);
    end
end