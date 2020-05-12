function featVec=getFeatVec(img,r, blockSize)
%% This function returns the feature space of the image
%-----------------------------------------------
%  Parameters:
%  img-         resized image
%  r-           radius of LBP
%  blockSize-   size of the block(odd number only)
%-----------------------------------------------
%% pad the image
img_ori = img;
xpad = blockSize(1)-mod(size(img,1),blockSize(1));
ypad = blockSize(2)-mod(size(img,2),blockSize(2));
midBlockS = floor(blockSize ./ 2);
img = padarray(img, [xpad ypad],'post');
img = padarray(img, midBlockS);
[m,n]=size(img);
img_= padarray(img, [r r]);
[m_,n_]=size(img_);
ori_x=(r+1):(m_-r);
ori_y=(r+1):(n_-r);

%% calculate the LBP values
d0=img_(ori_x-r,ori_y-r)-img;  % top    left
d1=img_(ori_x,  ori_y-r)-img;  % left
d2=img_(ori_x+r,ori_y-r)-img;  % bottom left
d3=img_(ori_x+r,ori_y)  -img;  % bottom
d4=img_(ori_x+r,ori_y+r)-img;  % bottom right
d5=img_(ori_x,  ori_y+r)-img;  % right
d6=img_(ori_x-r,ori_y+r)-img;  % top    right
d7=img_(ori_x-r,ori_y)  -img;  % top
d=[d0(:) d1(:) d2(:) d3(:) d4(:) d5(:) d6(:) d7(:)];
LBPs=2.^(0:1:7)';  
LBPImg =reshape((d>0)*LBPs,m,n);
figure, imshow(mat2gray(LBPImg));

%% get the histogram of each pixel (feature space of the image)
featVec = single(zeros(size(img_ori,1),size(img_ori,2),256));
% wb = waitbar(0,'getting LBP feats');
for i = midBlockS(1)+1 : midBlockS(1)+size(img_ori,1)
    waitbar((i-midBlockS(1))/size(img_ori,1),wb,['Computing Feats... ' num2str((i-midBlockS(1))/size(img_ori,1)*100) '%']);
    for j = midBlockS(2)+1 : midBlockS(2)+size(img_ori,2)
        B = LBPImg(i-midBlockS(1):i+midBlockS(1), j-midBlockS(2):j+midBlockS(2));
%         feat = imhist(B);
        [feat, ~] = histcounts(B,256);
        featVec(i-midBlockS(1), j-midBlockS(2), 1:256) = feat;
    end
end
% delete(wb);
end
