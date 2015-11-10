clear all;
close all;
clc;

%% Load Baseline Object
InputDirectory = '/run/media/lewisli/Scratch/VelocityModels/Sumo/Surfaces/';
RealizationName = 'MidResolution.ssb@';

NumPoints = 714368;
NumPolys = 1428716;
NumSkip = 0;

BaselineObjectPath = [InputDirectory RealizationName];

BaselinePointLocations = reshape(ReadDeformations(BaselineObjectPath,...
    0,NumPoints*3,'float32'),[3, NumPoints])';

PlotPointCloud(BaselinePointLocations,100);

%% Truncate Baseline Object to remove first few points which skeletonize the 
% structure
dy = zeros(length(BaselinePointLocations)-1,3);
for i = 1:3
    y = BaselinePointLocations(:,i)';
    x = 1:1:length(BaselinePointLocations);
    dy(:,i)=diff(y)./diff(x);
end

GradientSum = sum(abs(dy),2);
[V,PointStartIndex] = max(abs(GradientSum));

% Truncated PointLocations
BaselinePointLocations = BaselinePointLocations(PointStartIndex+1:end,:);

%% Plot to verify
PlotPointCloud(BaselinePointLocations,100);

%% Cluster Salt Surface Points into Regions using K-Means
clear all;
load Sunday.mat;
NumRegions = 8;
BaselineRegionIndex = kmeans(BaselinePointLocations,NumRegions);

PlotPointCloud(BaselinePointLocations,100,BaselineRegionIndex);

%% Within each region, re-sort index according to distance to some far away point
CenterPoint = [0 -10000 -100000];
RegionSortedIndex = cell(NumRegions,1);
for i = 1:NumRegions
    display(['Sorting Region: ' num2str(i)]);
    RegionPtLoc = BaselinePointLocations(BaselineRegionIndex==i,:);
    RegionNorms = sqrt(sum((RegionPtLoc-repmat(CenterPoint,length(RegionPtLoc),1)).^2,2))/1000;
    [B,SortedIndex] = sort(RegionNorms);
    RegionSortedIndex{i} = SortedIndex;
end

%% Test on some realizations from Trial 3
DataDirectory = '/run/media/lewisli/Scratch/VelocityModels/Sumo/Realizations/Trial3/';
RealizationName = 'Trial3PerturbedSurface_Real_';
NumRealizations = 25;

NumPoints = 714368;
NumPolys = 1428716;
FloatSize = 4;
DoubleSize = 8;

NumSkip = NumPoints*3*FloatSize + NumPolys*4*DoubleSize + ...
   NumPoints*DoubleSize;
NumMagnitudes = NumPoints;
MagnitudeDataType = 'double';

NumTruncatedPointCount = NumPoints - PointStartIndex;

RealizationDeformations = zeros(NumTruncatedPointCount,NumRealizations);
RealizationsPointLocations = zeros(NumTruncatedPointCount,3,NumRealizations);

h = waitbar(0,'Please wait...');

for i = 1:NumRealizations
    waitbar((i/NumRealizations),h,['Reading ' RealizationName num2str(i)]);
    
    BinaryPath = [DataDirectory RealizationName num2str(i) '.ssb@'];
    
    RawPointLocation = reshape(ReadDeformations(BinaryPath,...
        0,NumPoints*3,'float32'),3,NumPoints)';
    RealizationsPointLocations(:,:,i) = RawPointLocation(PointStartIndex+1:end,:);
    
    RawDeformations = ReadDeformations(BinaryPath,NumSkip,...
        NumMagnitudes,MagnitudeDataType);
    RealizationDeformations(:,i) = RawDeformations(PointStartIndex+1:end,:);
end
close(h);

%% Smooth
Region = 5;
close all;

SmoothingSize = 25;
PlottingScaleFactor = 25;

figure(3)
RegionPtLoc = BaselinePointLocations(BaselineRegionIndex==Region,:);
RegionPtLoc = RegionPtLoc(RegionSortedIndex{Region},:);
PlotPointCloud(RegionPtLoc,25);
title(['Baseline Index for Region ' num2str(Region)]);

for i = 1:3
    
    RealizationNumber = i+5;
    
    RegionPtLoc = RealizationsPointLocations(:,:,RealizationNumber);
    RegionPtLoc = RegionPtLoc(BaselineRegionIndex==Region,:);
    
    RegionDeformation = RealizationDeformations(:,RealizationNumber);
    RegionDeformation = RegionDeformation(BaselineRegionIndex==Region,:);
    
    RegionPtLocSorted = RegionPtLoc(RegionSortedIndex{Region},:);
    
    RegionDeformationSorted = RegionDeformation(RegionSortedIndex{Region});
    
    % Try smoothing the region deformations
    RegionDeformationSmoothed = smooth(RegionDeformationSorted,SmoothingSize);
    
    figure(1)
    subplot(3,2,i*2-1);
    PlotPointCloud(RegionPtLocSorted,PlottingScaleFactor,RegionDeformationSorted);
    title(['Realization ' num2str(RealizationNumber) ' Raw']);
    colorbar;
    subplot(3,2,i*2);
    PlotPointCloud(RegionPtLocSorted,PlottingScaleFactor,RegionDeformationSmoothed);
    title(['Realization ' num2str(RealizationNumber) ' Smoothed']);
    colorbar;
    
    figure(2)
    subplot(3,1,i);
    plot(RegionDeformationSmoothed);
end

%% Sub-sample
Region = 4;
close all;

SmoothingSize = 100;

PlottingScaleFactor = 25;
SampleFactor = 3;
PlottingScaleFactor2 = round(PlottingScaleFactor/SampleFactor);


figure(3)
RegionPtLoc = BaselinePointLocations(BaselineRegionIndex==Region,:);
RegionPtLoc = RegionPtLoc(RegionSortedIndex{Region},:);
PlotPointCloud(RegionPtLoc,5);
title(['Baseline Index for Region ' num2str(Region)]);

for i = 1:3
    
    RealizationNumber = i+5;
    
    RegionPtLoc = RealizationsPointLocations(:,:,RealizationNumber);
    RegionPtLoc = RegionPtLoc(BaselineRegionIndex==Region,:);
    
    RegionDeformation = RealizationDeformations(:,RealizationNumber);
    RegionDeformation = RegionDeformation(BaselineRegionIndex==Region,:);
    
    RegionPtLocSorted = RegionPtLoc(RegionSortedIndex{Region},:);
    RegionDeformationSorted = RegionDeformation(RegionSortedIndex{Region});
    
    
    RegionPtLocSampled = downsample(RegionPtLocSorted,5);
    RegionDeformationSampled = downsample(RegionDeformationSorted,5);
    
    figure(1)
    subplot(3,2,i*2-1);
    PlotPointCloud(RegionPtLocSorted,PlottingScaleFactor,RegionDeformationSorted);
    title(['Realization ' num2str(RealizationNumber) ' Raw']);
    colorbar;
    subplot(3,2,i*2);
    PlotPointCloud(RegionPtLocSampled,PlottingScaleFactor2,RegionDeformationSampled);
    title(['Realization ' num2str(RealizationNumber) ' Sampled']);
    colorbar;
    
    figure(2)
    subplot(3,1,i);
    plot(RegionDeformationSampled);
    
end

