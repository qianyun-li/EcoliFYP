function [ballotBox1, ballotBox2] = vote(img,blockSize,nOL)
mask = ~(img == 0);
xStep = round(blockSize(1)/nOL);
yStep = round(blockSize(2)/nOL);
blockSize(1) = xStep * nOL;
blockSize(2) = yStep * nOL;
[m,n] = size(img);
xPad = blockSize(1) - mod(m,blockSize(1));
yPad = blockSize(2) - mod(n,blockSize(2));
img = padarray(img, [xPad yPad], 'post');
img = padarray(img, blockSize, 'both');
mask = padarray(mask, [xPad yPad], 'post');
mask = padarray(mask, blockSize, 'both');
ballotBox1 = uint32(zeros(size(img)));
ballotBox2 = ballotBox1;
xEnd = m-mod(m,blockSize(1))+1+2*blockSize(1);
yEnd = n-mod(n,blockSize(2))+1+2*blockSize(2);
nSeg1 = 3;  nSeg2 = 4;
%     vTh = 1500; aTh = 80;

[aTh,vTh] = autothresh(img, xStep, yStep, xEnd, yEnd, blockSize);

wb = waitbar(0,'Voting...');
for i = 1 : xStep : xEnd
    waitbar(i/xEnd,wb,['Computing k-means clustering... ' num2str(i/xEnd*100) '%']);
    for j = 1 : yStep : yEnd
        B = img(i : i+blockSize(1)-1, j : j+blockSize(2)-1);
        votingResult1 = false(size(B)); votingResult2 = votingResult1;
        
        if all(B==0,'all')
            continue;
        end
        v0 = var(double(B),0,'all');
        avg0 = mean(double(B),'all');
        if ((v0 < vTh) && (avg0 < aTh))
            continue;
        end
        
        %             wavelength = 2.^(0:2) * 4;
        %             orientation = 0:65:130;
        %             g = gabor(wavelength,orientation);
        %             gabormag = imgaborfilt(B,g);
        %             for q = 1:length(g)
        %                 sigma = 0.5*g(q).Wavelength;
        %                 gabormag(:,:,q) = imgaussfilt(gabormag(:,:,q),3*sigma);
        %             end
        %             nrows = size(B,1);
        %             ncols = size(B,2);
        %             [X,Y] = meshgrid(1:ncols,1:nrows);
        %             [~, SI] = graycomatrix(B, 'Offset', [2 0], 'Symmetric', true);
        %             GCImg  = imgaussfilt(rescale(SI));
        %             featureSet = cat(3,B,GCImg);
        %             [L1,C1] = imsegkmeans(featureSet,nSeg1,'NormalizeInput',true);
        %             [L2,C2] = imsegkmeans(featureSet,nSeg2,'NormalizeInput',true);
        
        [L1,C1] = imsegkmeans(B,nSeg1);  [L2, C2] = imsegkmeans(B,nSeg2);
        [~,index1] = sort(C1,'descend'); [~, index2] = sort(C2, 'descend');
        if ~all(C1==0)
            if any(mask(i : i+blockSize(1)-1, j : j+blockSize(2)-1)==0,'all')
                votingResult1(L1==index1(1)) = 1;
            else
                votingResult1(L1==index1(1) | L1==index1(2)) = 1;
            end
            ballotBox1(i : i+blockSize(1)-1, j : j+blockSize(2)-1) = ...
                ballotBox1(i : i+blockSize(1)-1, j : j+blockSize(2)-1) + uint32(votingResult1);
        end
        if ~all(C2==0)
            votingResult2(L2==index2(1) | L2==index2(2)) = 1;
            ballotBox2(i : i+blockSize(1)-1, j : j+blockSize(2)-1) = ...
                ballotBox2(i : i+blockSize(1)-1, j : j+blockSize(2)-1) + uint32(votingResult2);
        end
    end
end
ballotBox1 = ballotBox1(blockSize(1)+1:m+blockSize(1),blockSize(2)+1:n+blockSize(2));
ballotBox2 = ballotBox2(blockSize(1)+1:m+blockSize(1),blockSize(2)+1:n+blockSize(2));
delete(wb);
end

function [aTh, vTh] = autothresh(img, xStep, yStep, xEnd, yEnd, blockSize)
v = double([]); avg = v;
for i = 1 : xStep : xEnd
    for j = 1 : yStep : yEnd
        B = img(i : i+blockSize(1)-1, j : j+blockSize(2)-1);
        v = [v var(double(B),0,'all')];
        avg = [avg mean(double(B),'all')];
    end
end


vStep = 100;
x1 = 0:vStep:ceil(max(v));
[f1, ~] = ksdensity(v, x1);
%     tf = islocalmin(f1);
%     i = find(tf);
%     min1 = x1(i(1));

startIdx1 = 2;
[num1, vLoc] = findpeaks(f1(startIdx1:end),x1(startIdx1:end));
[~, index1] = max(num1);
max1 = vLoc(index1);

vTh = max1;
% %     vTh = min1 * 1.20;
%     vTh = (min1+max1)* 0.44;

aStep = 5;
x2 = 0:aStep:ceil(max(avg));
[f2, ~] = ksdensity(avg, x2);

startIdx2 = 4;
[num2, aLoc] = findpeaks(f2(startIdx2:end), x2(startIdx2:end));
[~, index2] = max(num2);
max2 = aLoc(index2);

tf_f = islocalmin(f2);
i_f = find(tf_f > 0);

if(size(i,2) == 1)
    diff1 = [0 diff(f2)];
    tf_diff = islocalmin(diff1);
    i_diff = find(tf_diff > 0);
    min2 = x2(i_diff(2)) + aStep;
else
    min2 = x2(i_f(2));
end

aTh = (min2 + max2) * 0.43;

%     figure("Name","variance histogram"); histV = histogram(v); histV; %function histcounts
%     figure("Name","average  histogram"); histAvg = histogram(avg); histAvg;
%     edgeV = histV.BinEdges; edgeAvg = histAvg.BinEdges;
%     bCountsV = histV.BinCounts; bCountsAvg = histAvg.BinCounts;
%     [~,locV]=findpeaks(bCountsV);
%     [~,locAvg]=findpeaks(bCountsAvg);
%     vTh =((edgeV(max(locV))+edgeV(max(locV)+1))/2 + edgeV(2)/2) * 0.5;
%     aTh =((edgeAvg(max(locAvg))+edgeAvg(max(locAvg)+1))/2 + edgeAvg(2)/2)* 0.6;
%     vTh = edgeV(max(locV));
%     aTh = edgeAvg(max(locAvg));
%     vTh =((edgeV(locV(end))+edgeV(locV(end)+1))/2 + edgeV(2)/2)/2;
%     aTh =((edgeAvg(locAvg(end))+edgeAvg(locAvg(end)+1))/2 + edgeAvg(2)/2)*0.7;
%     disp(["aTh: ",num2str(aTh), " vTh", num2str(vTh)]);
end
