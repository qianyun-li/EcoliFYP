function [numCellsMin,numCellsMax]  = colonyCount(bw)
    allCells = sum(bw(:) == 1);
    
    D = bwdist(~bw);
    mask = imextendedmax(D, 0.7);
    % figure, imshowpair(bw, mask, 'blend')
    D = -D;
    img_mod = imimposemin(D, mask);
    L = watershed(img_mod);

    bwWS = bw;
    bwWS(L==0) = 0;
%     figure, imshow(bwWS);

    cc = bwconncomp(bwWS);
    numPixels = cellfun(@numel, cc.PixelIdxList);

    x = 0:25:max(numPixels);
    [f, ~] = ksdensity(numPixels,x);
    [counts, loc] = findpeaks(f,x);
    
    [~, idx] = max(counts);
    cellSize = loc(idx);
    
%     x = 0:50:max(numPixels);
%     [counts, ~] = histcounts(numPixels,x);
%     [~, idx] = max(counts);
% %     cellSize = (x(idx) + x(idx+1)) * 0.5;
%     cellSizeMin = x(idx);
%     cellSizeMax = x(idx+1);

    cellSizeMin = cellSize * 0.95;
    cellSizeMax = cellSize * 1.05;
    
    numCellsMin = round(allCells / cellSizeMax);
    numCellsMax = round(allCells / cellSizeMin);
end