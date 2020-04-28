function LBPImg=getLBPImg(img,r)
%% This function returns the image with LBP values
%-----------------------------------------------
%  Parameters:
%  img-         resized image
%  r-           radius of LBP
%-----------------------------------------------
%% pad the image
img = double(img);
[m,n]=size(img);
m_=m+2*r; n_=n+2*r; 
img_=zeros(m_,n_);
ori_x=(r+1):(m_-r);
ori_y=(r+1):(n_-r);
img_(ori_x,ori_y)=img;

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
LBPs=2.^(7:-1:0)';  
LBPImg =reshape((d>=0)*LBPs,m,n);
end
