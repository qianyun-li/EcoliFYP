function [numCellsMin,numCellsMax]  = countCell(img, bw)
    allCells = sum(bw(:) == 1);
    
    D = bwdist(~bw);
    mask = imextendedmax(D, 0.8);
    % figure, imshowpair(bw, mask_em, 'blend')
    D = -D;
    img_mod = imimposemin(D, mask);
    L = watershed(img_mod);

%     mask_em = imextendedmax(img, 10);
%     img_c = imcomplement(img);
%     img_mod = imimposemin(img_c, ~bw | mask_em);
%     L = watershed(img_mod);

%     bw2 = bw;
%     bw2(L==0) = 0;
%     figure, imshow(bw2);

    x = unique(L);
    N = numel(x);
    for k = 3:N
        count(k) = sum(L==x(k),'all');
    end
    
    x = 0:100:max(count);
    [f, ~] = ksdensity(count,x);
    [~, loc] = findpeaks(f,x);
    
    cellSize = loc(1);
    if loc(1) < 200
        cellSize = loc(2);
    end
    cellSizeMin = cellSize * 0.90;
    cellSizeMax = cellSize * 1.1;
    
    numCellsMin = allCells / cellSizeMax;
    numCellsMax = allCells / cellSizeMin;
end