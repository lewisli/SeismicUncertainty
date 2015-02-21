function [ SaltMask ] = GenerateSaltMask( CurrentDepthSlice, SaltVelocity,...
    CurrentDepth)
%GenerateSaltMask Summary of this function goes here
%   Detailed explanation goes here

threshold_lower = SaltVelocity - 1;
threshold_upper = SaltVelocity + 1;
lower_spatial_bound = 1152;

% Threshold image
% This hack is used to account for dirty salt at shallower depths
if (CurrentDepth < 700)
    threshold_lower = 4100;
else
    threshold_lower = 4479;
end

% Binraize image
CurrentDepthSlice((CurrentDepthSlice>threshold_lower) & ...
    (CurrentDepthSlice < threshold_upper)) = 1;
CurrentDepthSlice(CurrentDepthSlice>1) = 0;

% Fill holes smaller than a certain size
fill_sample = ~bwareaopen(~CurrentDepthSlice, 1500);

% Get connect components
CC = bwconncomp(fill_sample,8);

% Get size of each connected components
numPixels = cellfun(@numel,CC.PixelIdxList);

% Remove Small components
smallBodiesIndex = find(numPixels<4500);

for ii = 1:length(smallBodiesIndex)
    idx = smallBodiesIndex(ii);
    fill_sample(CC.PixelIdxList{idx}) = 0;
end

% Remove anticline
if (CurrentDepth > 912 && CurrentDepth < lower_spatial_bound)
    [~, I] = sort(numPixels,'descend');
    if (CurrentDepth < 940)
        removalIndex = I(3);
    elseif (CurrentDepth < 1050)
        removalIndex = I(2);
    else
        removalIndex = I(1);
    end
    fill_sample(CC.PixelIdxList{removalIndex}) = 0;
end

SaltMask = fill_sample;

end

