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

if(size(i_f,2) == 1)
    min2 = x2(i_f(1));
    aTh = (min2 + max2) * 0.54;
else
    min2 = x2(i_f(2));
    aTh = (min2 + max2) * 0.43;
end

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