function icon = getIcon(im, centers, c)
% Crop out the icon based on the circles
radius = 18;
xMin = centers(c, 1)-radius;
yMin = centers(c, 2)-radius;
size = radius*2+1;
cropRect = round([xMin, yMin, size, size]);
icon = imcrop(im, cropRect);
prCrop = icon;

% Blacken out background by making a circular mask for better SSIM
cropRad = 16;
angles = linspace(0, 2*pi, 10000);
x = cos(angles) * cropRad + cropRad;
y = sin(angles) * cropRad + cropRad;
mask = poly2mask(x+3, y+3, size+1, size+1);

% Seperate into color channels
redChannel = icon(:, :, 1);
greenChannel = icon(:, :, 2);
blueChannel = icon(:, :, 3);

% Mask background
redChannel(~mask) = 0;
greenChannel(~mask) = 0;
blueChannel(~mask) = 0;

icon = cat(3, redChannel, greenChannel, blueChannel);
end