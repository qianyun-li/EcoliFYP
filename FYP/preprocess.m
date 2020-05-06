function img = preprocess(img)
    % Fix image size to 2200 x 2200
    img = imresize(img, 2200 / size(img,2));

    mask = ~(img == 0);
    
    w = 25; img_filtered = img;
    img_filtered(mask==0) = round(mean(img,'all'));
    img_filtered = roifilt2(img_filtered,mask,@(x) ordfilt2(x,1,ones(w,w),'symmetric'));
    img_filtered = roifilt2(img_filtered,mask,@(x) imfilter(x,ones(w,w)/(w*w),'symmetric'));
    img = imsubtract(img,img_filtered);
    img = roifilt2(img,mask,@(x) imadjust(x,stretchlim(x)));

%     img = medfilt2(img);
    img = imgaussfilt(img,0.75);
    
    img = imadjust(img);
%     img = adapthisteq(img);
    
    SE = strel('disk',7);
    img = imopen(img,SE);
end