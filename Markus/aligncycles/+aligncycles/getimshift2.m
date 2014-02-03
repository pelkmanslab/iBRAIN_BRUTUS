function [Y, X] = getimshift2(RefImFilename,Im2RegFilename,scaleFactor)

Im1 = imread(RefImFilename);
Im2 = imread(Im2RegFilename);

nIm1 = Im1(1:scaleFactor:end,1:scaleFactor:end);
nIm2 = Im2(1:scaleFactor:end,1:scaleFactor:end);

tic
oIm = filter2(nIm1,nIm2);
toc

[R, C] = find(oIm == max(oIm(:)));
S = size(oIm)./2;

Y = (S(1) -R)*scaleFactor;
X = (S(2) -C)*scaleFactor;

end