function main()
% Variables
objPol = 'bright';
sensitivity = 0.98;
edgeThresh = 0.95;
circleRad = [14 18];

enemyIcons = {};
enemies = 3;
enemySaved = 1;
removeOverlap = 1;

vidobj = videoinput('winvideo', 4, 'I420_1920x1080');

while(true)
    % Get processing images
    [mapRGB, ~] = getMap(vidobj); % Get image of minimap
    imIso = isolateRed(mapRGB); % Isolate the red enemy cirlces
    imRefi = refineIm(imIso); % Refine the edges
    
    % Find all the circles in grayscale image
    [centers, radii, metrics] = imfindcircles(imRefi, circleRad, ...
        'Method', 'PhaseCode', ...
        'objectpolarity', objPol, ...
        'sensitivity', sensitivity, ...
        'edgethreshold', edgeThresh);
    
    % If more than 1 circle, remove overlapping finds
    if size(centers, 1) > 1 & removeOverlap == 1
        [centers, radii, metrics] = solveOverlap(centers, radii, metrics);
    end
    
    % Loop through all circles current on map and process
    imshow(mapRGB);
    viscircles(centers, radii, 'Color', 'b');
    % Array holding current knowledge of enemies on map or not
    enemyOnMap = zeros(enemies, 1);
    for c = 1:size(centers, 1)
        % If not a good circle, move to next one. Ensure decent templates
        if metrics(c) < 0.01
            continue;
        end
        
        % Check if icon is already logged in our list using normxcorr2
        % If similar image found, set logged to true and break
        icon = getIcon(mapRGB, centers, c);
        alreadyTracked = 0;
        for cell = 1:length(enemyIcons)
            enemy = cell2mat(enemyIcons{cell, 1});
            % Calculate normxcorr2
            corrMat = getAvgNormxcorr2(icon, enemy);
            maxVal = max(corrMat(:));
            
            % Only if both match well then we have already tracked it
            if maxVal > 0.70
                viscircles(centers(c, :), 16, 'Color', 'g');
                text(centers(c,1)+15, centers(c,2)+15, string(cell), 'FontWeight', 'Bold', 'Color', 'g');
                alreadyTracked = 1;
                enemyOnMap(cell, 1) = 1;
                break;
            end
        end
        
        % If not tracked, load this one into our database if it has
        % good metrics until we have all enemies tracked, then stop loads
        % Load both cropped image for comparison and
        % Uncropped image for future template matching
        if alreadyTracked == 0 & length(enemyIcons) < enemies
            if metrics(c) > 0.05
                disp(length(enemyIcons));
                enemyIcons{enemySaved, 1} = {icon}; %#ok<AGROW>
                enemySaved = enemySaved + 1;
            end
            % If we found the amount of enemies intended, no longer worry
            % about overlap
            if length(enemyIcons) >= enemies
                removeOverlap = 0;
            end
        end
    end
    
    % Print message for each missing enemy
    for i = 1:length(enemyIcons)
        fprintf("Enemy %i on map: %i\n", i, enemyOnMap(i, 1));
    end
    fprintf("===================\n");
end
end