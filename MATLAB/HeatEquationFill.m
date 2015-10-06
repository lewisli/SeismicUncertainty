function [ OutputImage ] = HeatEquationFill( InputImage, NumIterations, ...
    FilterSize)
% HeatEquationFill Takes an image containing a salt body, (set to 0), and
% interpolates the boundary back in.
%
% This assumes that original image has been pre-processed such that the
% salt locations has been specified as 0. This works by solving the
% linear heat equuation, by specifiying the intensity of the boundaries
% around the salt body and flowing them in. Takes quite a few iterations.
%
% Input Parameters: 
%
% InputImage: Velocity model with salt locations set to 0
% NumIterations: Number of times to apply filter
% FilterSize: Filter Dimensions
%
% Lewis Li (lewisli@stanford.edu)
% Date of Creation: Feburary 24th 2014
% Last Updated: September 23rd 2015

if nargin < 3
    NumIterations = 60;
    FilterSize = 18;
end

EmptyPixels = (InputImage == 0);
EmptyPixels = imdilate(EmptyPixels, ones(8));

OutputImage = imfilter(InputImage,fspecial('gaussian',[1 1]*100,50),'same');
OutputImage(~EmptyPixels) = InputImage(~EmptyPixels);

for count = 1:NumIterations
    OutputImage = imfilter(OutputImage, fspecial('average', ...
        [1,1]*FilterSize), 'circular');
    OutputImage(~EmptyPixels) = InputImage(~EmptyPixels);
end

end

