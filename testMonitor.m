function testMonitor(imIn)
    % Variables
    objPol = 'bright';
    sensitivity = 0.99;
    edgeThresh = 0.95;
    circleRad = [15 35];

        % Isolate colors for allies and enemies for clearer circles
        % ================================================
        % Extract the individual red, green, and blue color channels.
        redChannel = imIn(:, :, 1);
        greenChannel = imIn(:, :, 2);
        blueChannel = imIn(:, :, 3);
        
        % Create mask of only red colors and mask of inverse
        redMask = redChannel >= 200 & greenChannel <= 100 & blueChannel <= 100;
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
        imMask = cat(3, redChannel, greenChannel, blueChannel);
        imMask = rgb2gray(imMask);

        % Create a small square strel just to increase size of circles
        % slightly so when applying med filter large parts of circle
        % doesn't disappear
        s = strel('disk', 1);
        imDilate = imdilate(imMask, s);
        imshow(imDilate);
        pause; 
        
        % Apply the median filter to slightly dilated image to get rid of
        % scattered red pieces
        imFilt = medfilt2(imDilate, [6 6]);
        imshow(imFilt);
        pause;
        
        % Dilate again to fill out any missing parts of circle removed
        s = strel('square', 2);
        imDilate = imdilate(imFilt, s);
        imshow(imDilate);
        pause;
        
        imshow(imIn);
        
        imCirc = imDilate;
        % Find all the circles in grayscale image
          [centers, radii] = imfindcircles(imCirc, circleRad, ...
              'objectpolarity', objPol, ...
              'sensitivity', sensitivity, ...
              'edgethreshold', edgeThresh);
          
        % Draw the circle perimeter for all circles onto minimap
        viscircles(centers, radii, 'Color', 'g');
        
        % Update statistics
        eOnScreen = numel(radii);
        text = [num2str(eOnScreen), ' enemies on screen'];
        disp(text);
      
        pause;
end