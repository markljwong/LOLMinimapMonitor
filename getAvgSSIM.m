function ssimAvg = getAvgSSIM(temp, im)
% Get SSIM of every color channel
ssimR = ssim(temp(:,:,1), im(:,:,1));
ssimG = ssim(temp(:,:,2), im(:,:,2));
ssimB = ssim(temp(:,:,3), im(:,:,3));

% Average 
ssimAvg = ssimR + ssimG + ssimB;
ssimAvg = ssimAvg/3;
end