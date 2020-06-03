function imgSeg = kmeansCluster(img,blockSize, nOL,tVote)
        [ballotBox1,ballotBox2] = vote(img,blockSize,nOL);
        imgSeg1 = false(size(ballotBox1)); imgSeg2 = imgSeg1;
        imgSeg1(ballotBox1 >= tVote * nOL^2) = 1;
        imgSeg2(ballotBox2 >= tVote * nOL^2) = 1;
        imgSeg = imgSeg1&imgSeg2;
end