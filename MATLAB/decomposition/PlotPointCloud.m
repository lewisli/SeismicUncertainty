function [ h ] = PlotPointCloud( PointLocations, DownsampleFactor, C )
%PlotPointCloud Draws a point cloud
%   Plots a point cloud with given color, if no color is given, plot
%   according to index. Downsample by a factor so plotting doesn't lag.

NumPoints = length(PointLocations);

if (nargin < 3)
    C = linspace(1,100,NumPoints);
end
    
SampledPointLocations = downsample(PointLocations,DownsampleFactor);
SampledC = downsample(C,DownsampleFactor);

h = scatter3(SampledPointLocations(:,1),SampledPointLocations(:,2),...
    SampledPointLocations(:,3),55,SampledC,'Filled');

end

