function iso = isolateRed(im)
% Isolate the enemy red circles
% ================================================
% Extract the individual red, green, and blue color channels.
redChannel = im(:, :, 1);
greenChannel = im(:, :, 2);
blueChannel = im(:, :, 3);

% Create mask of only red colors and mask of inverse
redMask = redChannel >= 150 & greenChannel <= 100 & blueChannel <= 100;
redMaskInv = imcomplement(redMask);

% Set those areas to be white
redChannel(redMask) = 255;
greenChannel(redMask) = 255;
blueChannel(redMask) = 255;

% Make everything not in those areas black
redChannel(redMaskInv) = 0;
greenChannel(redMaskInv) = 0;
blueChannel(redMaskInv) = 0;

% Recombine separate color channels into a single image
% and make it grayscale
iso = cat(3, redChannel, greenChannel, blueChannel);
iso = rgb2gray(iso);
end