function minimapMonitor(im)
    % Variables
    objPol = 'bright';
    sensitivity = 0.99;
    edgeThresh = 0.95;
    circleRad = [15 35];
    
    eOnScreen = 0;

    while(true)
        % Image acquisition 
        % ===============================================
        % Take screen capture of whole screen
        set(0,'units','pixels');
        screen = get(0,'ScreenSize'); % screen size
        
        % Use jaba Robot class to capture screen
        robot = java.awt.Robot();
        rect = java.awt.Rectangle(0, 0, screen(3), screen(4));
        capture = robot.createScreenCapture(rect);
        
        % Get image details
        h = capture.getHeight;
        w = capture.getWidth;
        
        % Convert to an RGB image
        imRGB = typecast(capture.getRGB(0, 0, w, h, [] ,0, w), 'uint8');
        imDat = zeros(h, w, 3, 'uint8');
        imDat(:, :, 1) = reshape(imRGB(3:4:end), w, [])';
        imDat(:, :, 2) = reshape(imRGB(2:4:end), w, [])';
        imDat(:, :, 3) = reshape(imRGB(1:4:end), w, [])';
        
        % Crop image to the minimap and show
        imCrop = imcrop(imDat, [w-w/4, h-h/2.5 w, h]);

        % Isolate colors for allies and enemies for clearer circles
        % ================================================
        % Extract the individual red, green, and blue color channels.
        redChannel = imCrop(:, :, 1);
        greenChannel = imCrop(:, :, 2);
        blueChannel = imCrop(:, :, 3);
        
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

        % Filter and dilate to make circles more pronounced
        % =========================================================
        imshow(imCrop);

        % Create a small square strel just to increase size of circles
        % slightly so when applying med filter large parts of circle
        % doesn't disappear
        s = strel('disk', 1);
        imDilate = imdilate(imMask, s);
        
        % Apply the median filter to slightly dilated image to get rid of
        % scattered red pieces
        imFilt = medfilt2(imDilate, [6 6]);
        
        % Dilate again to fill out any missing parts of circle removed
        s = strel('square', 2);
        imDilate = imdilate(imFilt, s);
        
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
end