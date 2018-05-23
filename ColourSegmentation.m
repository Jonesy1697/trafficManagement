im = imread('fire01.jpg');

mask = roipoly(im);

red = immultiply(mask, im(:,:,1));
green = immultiply(mask, im(:,:,2));
blue = immultiply(mask, im(:,:,3));

g = cat(3, red, green, blue);

[M,N,K] = size(g);

I = reshape(g, M*N, 3);

idx = find(mask);

I = double(I(idx,1:3));

[C,m] = covmatrix(I);

d = diag(C);
sd = sqrt(d); 

t = 10;

seg = colorseg('euclidean', im, t, m);
figure, imshow(seg);