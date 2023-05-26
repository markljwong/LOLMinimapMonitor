function corrMat = getAvgNormxcorr2(temp, im)
% Get normxcorr2 of every color channel
corrMatR = normxcorr2(temp(:,:,1), im(:,:,1));
corrMatG = normxcorr2(temp(:,:,2), im(:,:,2));
corrMatB = normxcorr2(temp(:,:,3), im(:,:,3));

% Take average
corrMat = corrMatR + corrMatG + corrMatB;
corrMat = corrMat/3;
end