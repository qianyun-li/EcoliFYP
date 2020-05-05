function [numCellsMin,numCellsMax]  = countCell(img, bw)
%     cc = bwconncomp(img);
%     numPixels = cellfun(@numel, cc.PixelIdxList);
%     [bCounts, edges] = histcounts(numPixels);
% %     figure("Name","cell size histogram");
% %     hist = histogram(numPixels); hist;
% %     bCounts = hist.BinCounts; edges = hist.BinEdges;
%     [~, index] = max(bCounts);
%     cellSizeMin = (edges(index) + edges(index+1)) * 0.40;
%     cellSizeMax = (edges(index) + edges(index+1)) * 0.60;
%     allCells = sum(img(:) == 1);
%     numCellsMin = allCells / cellSizeMin;
%     numCellsMax = allCells / cellSizeMax;
    allCells = sum(bw(:) == 1);
    
    mask_em = imextendedmax(img, 10);
    img_c = imcomplement(img);
    img_mod = imimposemin(img_c, ~bw | mask_em);
    L = watershed(img_mod);
    x = unique(L);
    N = numel(x);

    for k = 1:N
        count(k) = sum(L==x(k),'all');
    end
    
    [~, edges] = histcounts(count(3:end));
    [f, xi] = ksdensity(count,edges(1):100:edges(end));
    [~, loc] = findpeaks(f, edges(1):100:edges(end));
    
    cellSize = loc(1);
    if loc(1) < 200
        cellSize = loc(2);
    end
    cellSizeMin = cellSize * 0.95;
    cellSizeMax = cellSize * 1.15;
    
%     [~, i] = max(counts);
%     cellSizeMin = edges(i);
%     cellSizeMax = edges(i+1);
    
    numCellsMin = allCells / cellSizeMax;
    numCellsMax = allCells / cellSizeMin;
end