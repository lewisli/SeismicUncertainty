clear all;

InputDirectory = '/run/media/lewisli/Scratch/VelocityModels/Sumo/Surfaces/';
RealizationName = 'MidResolution.ssb@';

NumPoints = 714368;
NumPolys = 1428716;

NumSkip = 0;
BinaryPath = [InputDirectory RealizationName];
PointLocations = ReadDeformations(BinaryPath,0,NumPoints*3,'float32');
RawPointLocations = reshape(PointLocations,[3,NumPoints])';
PointLocations = downsample(RawPointLocations,5);

%% Calculate coordinate gradients
dy = zeros(length(PointLocations)-1,3);
for i = 1:3
    y = PointLocations(:,i)';
    x = 1:1:length(PointLocations);
    dy(:,i)=diff(y)./diff(x);
end

GradientSum = sum(abs(dy),2);
[V,I1] = max(abs(GradientSum));

% Truncated PointLocations
TruncatedPointLocations = PointLocations(I1+2:end,:);
TruncatedGradients = GradientSum(I1+1:end);


%%
subplot(211);
plot(TruncatedPointLocations);
subplot(212);
plot(TruncatedGradients);

%%
[HighPeaksLocations,col]  = find(TruncatedGradients>1200);
GroupIndex = zeros(length(TruncatedGradients),1);
GroupNumber = 1;

for i = 1:length(TruncatedGradients)
    if (i < HighPeaksLocations(GroupNumber))
        GroupIndex(i) = GroupNumber;
    elseif (i == HighPeaksLocations(GroupNumber))
        GroupNumber= min(GroupNumber + 1,length(HighPeaksLocations));
        GroupIndex(i) = GroupNumber;
    else
        GroupIndex(i) = length(HighPeaksLocations)+1;
        GroupNumber = length(HighPeaksLocations);
    end
end

subplot(211);
plot(GroupIndex);
subplot(212);
plot(TruncatedGradients);

%% Subsample For Display

% Down scale factor
DownScaleFactor = 25;
idx = kmeans(TruncatedPointLocations,8);

SampledPoints = downsample(TruncatedPointLocations,DownScaleFactor);
SampledGroupIndex = downsample(GroupIndex,DownScaleFactor);
Sampledidx = downsample(idx,DownScaleFactor);

%SampledGroupIndex(SampledGroupIndex<5) = 0;
%SampledGroupIndex(SampledGroupIndex>=5) = 1;



scatter3(SampledPoints(:,1),SampledPoints(:,2),SampledPoints(:,3),55,Sampledidx,'Filled');
colormap hsv;
%[HighPeaks,PeakIndex] = find(pks > 1000);

%plot(HighPeaks);

% HighLoc = locs(PeakIndex');

% plot(HighLoc,HighPeaks,'*');


%% Use K-means to decompose points into regions...
% idx is a vector of length(PointLocations) which contains the points at
% each location. We need to re-sort the index in a coherent manner
CenterPoint = [0 0 1000000];
RegionPtLoc = downsample(TruncatedPointLocations(idx==2,:),10);
RegionNorms = sqrt(sum((RegionPtLoc-repmat(CenterPoint,length(RegionPtLoc),1)).^2,2))/1000;

[B,SortedIndex] = sort(RegionNorms);

% SortedIndex contains the index of the points sorted in terms of norm,
% plotting on this index should be smoother...

RegionPtLocSorted = RegionPtLoc(SortedIndex,:);
C = linspace(0,100,length(RegionPtLocSorted));
%scatter3(RegionPtLoc(:,1),RegionPtLoc(:,2),RegionPtLoc(:,3),55,RegionNorms,'Filled');

%% Load in perturbation magnitude from Trial 3

DataDirectory = '/run/media/lewisli/Scratch/VelocityModels/Sumo/Realizations/Trial3/';
RealizationName = 'Trial3PerturbedSurface_Real_';
NumRealizations = 25;

NumPoints = 714368;
NumPolys = 1428716;
NumNormals = NumPoints*3;
FloatSize = 4;
DoubleSize = 8;

NumSkip = NumPoints*3*FloatSize + NumPolys*4*DoubleSize + ...
   NumPoints*DoubleSize;
NumMagnitudes = NumPoints;
MagnitudeDataType = 'double';

% First try using the deformations on the surfaces themselves
RawDeformations = zeros(NumRealizations, NumMagnitudes);

RealizationsPointLocations = zeros(NumPoints,3,NumRealizations);
PointLocations = ReadDeformations(BinaryPath,0,NumPoints*3,'float32');


h = waitbar(0,'Please wait...');
for i = 1:NumRealizations
    waitbar((i/NumRealizations),h,['Reading ' RealizationName num2str(i)]);
    
    %display(['Reading raw deformations for '  RealizationName num2str(i)]);
    BinaryPath = [DataDirectory RealizationName num2str(i) '.ssb@'];
    RealizationNames{i} = [RealizationName num2str(i)];
    
    RealizationsPointLocations(:,:,i) = reshape(ReadDeformations(BinaryPath,0,NumPoints*3,'float32'),...
        NumPoints,3);
    RawDeformations(i,:) = ReadDeformations(BinaryPath,NumSkip,...
        NumMagnitudes,MagnitudeDataType);
end
close(h);

%% Plot Raw Deformations
plot(RawDeformations(1,:))

%% Truncate the Raw Deformations to not include the first I1 Elements
RawDeformationsTruncated = RawDeformations(:,I1+1:end);
RawPointLocTruncated = RealizationsPointLocations(I1+1:end,:,:);

%%

RealizationsPointLocationsRegion1 = RawPointLocTruncated(SortedIndex,:,1);
%RawDeformationRegion = RawDeformationsTruncated(:,SortedIndex);

scatter3(RealizationsPointLocationsRegion1(:,1),RealizationsPointLocationsRegion1(:,2),RealizationsPointLocationsRegion1(:,3),55);
%%
plot(RawDeformationRegion(1,:))