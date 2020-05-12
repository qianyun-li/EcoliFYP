function[dx,dy] = SobelEdgeOperator(pic)
    [m,n] = size(pic);
    pic = double(pic);
    dx = double(zeros(size(pic))); dy = dx;
    sx = [-1  0  1;-2 0 2;-1 0 1]; sy = sx';
    for i = 2:m-1
        for j = 2:n-1
            original = pic(i-1:i+1,j-1:j+1);
            dx(i,j) = sum(sum(original .* sx)) ./ 8;
            dy(i,j) = sum(sum(original .* sy)) ./ 8;
        end
    end     
end