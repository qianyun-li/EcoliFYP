function [ballotBox1, ballotBox2] = vote1(img,blockSize,nOL,mask)
    global xStep yStep xEnd yEnd blockSize;
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
    wb = waitbar(0,'Voting...');
    xEnd = m-mod(m,blockSize(1))+1+2*blockSize(1);
    yEnd = n-mod(n,blockSize(2))+1+2*blockSize(2);
    nSeg1 = 3;  nSeg2 = 4;
%     vTh = 1500; aTh = 80;

    [aTh,vTh] = autothresh(img);

    for i = 1 : xStep : xEnd
        waitbar(i/xEnd,wb,['Computing... ' num2str(i/xEnd*100) '%']);
        for j = 1 : yStep : yEnd
            B = img(i : i+blockSize(1)-1, j : j+blockSize(2)-1);
            votingResult1 = false(size(B)); votingResult2 = votingResult1;

            if all(B==0,'all')
                continue;
            end
            v0 = var(double(B),0,'all');
            avg0 = mean(double(B),'all');        
            if ((v0 < vTh) & (avg0 < aTh))
                continue;
            end
            
            B = cat(3, B, rescale(imfill(stdfilt(B))));
            
            [L1,C1] = imsegkmeans(B,nSeg1);  [L2, C2] = imsegkmeans(B,nSeg2);
            [~,index1] = sort(C1,'descend'); [~, index2] = sort(C2, 'descend');
            if ~all(C1==0)
                if any(mask(i : i+blockSize(1)-1, j : j+blockSize(2)-1)==0,'all')
                    votingResult1(L1==index1(1)) = 1;
                else
                    votingResult1(L1==index1(1) | L1==index1(2)) = 1;
                end
                ballotBox1(i : i+blockSize(1)-1, j :    j+blockSize(2)-1) = ...
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

function [aTh, vTh] = autothresh(img)
    global xStep yStep xEnd yEnd blockSize;
 
    v = double([]); avg = v;
    for i = 1 : xStep : xEnd
        for j = 1 : yStep : yEnd
             B = img(i : i+blockSize(1)-1, j : j+blockSize(2)-1);
             v = [v var(double(B),0,'all')];
             avg = [avg mean(double(B),'all')];
        end
    end
    
    [~, edgeV] = histcounts(v);
    vStep = edgeV(2)-edgeV(1);
    [f1, xi1] = ksdensity(v, 0:vStep:edgeV(end));
    [~, vLoc] = findpeaks(f1);
    vTh = (xi1(vLoc(1)) + vStep / 2) * 0.65;
    
    [~, edgeAvg] = histcounts(avg);
    aStep = edgeAvg(2)-edgeAvg(1);
    [f2, xi2] = ksdensity(avg, 0:aStep:edgeAvg(end));
    [~, aLoc] = findpeaks(f2);
    aTh = (xi2(aLoc(1)) + aStep / 2) * 0.65;
    
%     figure("Name","variance histogram"); histV = histogram(v); histV; %function histcounts
%     figure("Name","average  histogram"); histAvg = histogram(avg); histAvg;
%     edgeV = histV.BinEdges; edgeAvg = histAvg.BinEdges;
%     bCountsV = histV.BinCounts; bCountsAvg = histAvg.BinCounts;
%     [bCountsV, edgeV] = histcounts(v);
%     [bCountsAvg, edgeAvg] = histcounts(avg);
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