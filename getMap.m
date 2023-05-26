function [mapRGB, mapGray] = getMap(vidobj)
% Load in template for minimap and convert to gray
mapTemp = imread('mapTemp1080.png');
mapTemp = rgb2gray(mapTemp);

% Image acquisition
% ===============================================
im = getsnapshot(vidobj);
imRGB = ycbcr2rgb(im);
imGray = rgb2gray(im);

% Crop the image to only minimap if found
% ===============================================
corrMat = normxcorr2(mapTemp, imGray);
[ypeak, xpeak] = find(corrMat==max(corrMat(:)));
yOffSet = ypeak-size(mapTemp,1);
xOffSet = xpeak-size(mapTemp,2);

rect = [xOffSet, yOffSet, size(mapTemp, 2), size(mapTemp,1)];
mapRGB = imcrop(imRGB, rect);
mapGray = imcrop(imGray, rect);
mapGray = imadjust(mapGray);
end