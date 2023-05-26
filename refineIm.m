function ref = refineIm(im)
% Make circles more pronounced and remove extraneous objects
% =========================================================
% Convert to black and white image
im = imbinarize(im);

% Create a disk strel and dilate to connect
% the circles into mostly one piece
s = strel('disk', 2);
im = imdilate(im, s);
im = imdilate(im, s);

% Use regionprops to find the largest connected regions
% Assume anything with area smaller than 600 is not a 'real' circle
% Remove them
props = regionprops(im, 'Area');
areas = [props.Area];
ind = areas > 700;
cc = bwconncomp(im);
for i = 1:length(ind)
    if ind(i) == 0
        im(cc.PixelIdxList{i}) = 0;
    end
end

% Erode away the "thickness" of the circle for more accurate centers
im = imerode(im, s);

ref = im;
end