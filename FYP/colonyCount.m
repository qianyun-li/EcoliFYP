function [numCellsMin,numCellsMax]  = colonyCount(bw)
    allCells = sum(bw(:) == 1);
    
    D = bwdist(~bw);
    mask = imextendedmax(D, 0.9);
    % figure, imshowpair(bw, mask_em, 'blend')
    D = -D;
    img_mod = imimposemin(D, mask);
    L = watershed(img_mod);

    bwWS = bw;
    bwWS(L==0) = 0;
%     figure, imshow(bwWS);

    cc = bwconncomp(bwWS);
    numPixels = cellfun(@numel, cc.PixelIdxList);

    x = 0:50:max(numPixels);
    [f, ~] = ksdensity(numPixels,x);
    [~, loc] = findpeaks(f,x);
    
    cellSize = loc(1);
    if loc(1) < 200
        cellSize = loc(2);
    end
    
%     x = 0:50:max(numPixels);
%     [counts, ~] = histcounts(numPixels,x);
%     [~, idx] = max(counts);
% %     cellSize = (x(idx) + x(idx+1)) * 0.5;
%     cellSizeMin = x(idx);
%     cellSizeMax = x(idx+1);

    cellSizeMin = cellSize * 0.95;
    cellSizeMax = cellSize * 1.05;
    
    numCellsMin = fix(allCells / cellSizeMax);
    numCellsMax = fix(allCells / cellSizeMin);
end