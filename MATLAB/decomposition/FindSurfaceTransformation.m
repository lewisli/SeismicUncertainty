
% High resolution basecase
clear all;
DataDir = '/media/Scratch/VelocityModels/Sumo/Surfaces/';

%% Case 1 (High)
NumPoints1 = 3129227;
RealizationName = 'HighResolution.ssb@';
BinaryPath = [DataDir RealizationName];
PointLocations1 = ReadDeformations(BinaryPath,0,NumPoints1*3,'float32');
RawPointLocations1 = reshape(PointLocations1,[3,NumPoints1])';

%% Case 2 (low Density)
RealizationName = 'MidResolution.ssb@';
NumSkip = 0;
NumPoints2 = 714368;
BinaryPath = [DataDir RealizationName];
PointLocations2 = ReadDeformations(BinaryPath,0,NumPoints2*3,'float32');
RawPointLocations2 = reshape(PointLocations2,[3,NumPoints2])';
RawPointNorms2 = sqrt(sum(RawPointLocations2.^2,2));

Color = linspace(1,100,length(RawPointLocations2));
y = RawPointNorms2';
x = 1:1:length(RawPointNorms2);
dy=diff(y)./diff(x);

[V,I1] = max(abs(dy));
%%

%Find closest point
%ClosestIndex = zeros(length(RawPointLocations2));

tic
StartIndex = I1+1;
EndIndex = length(RawPointLocations2);
k = dsearchn(RawPointLocations1,RawPointLocations2(StartIndex:EndIndex,:));
toc
save('FullMatchedIndex.mat','k');

%% Compute difference between the two
DifferenceMatrix = RawPointLocations2(StartIndex:EndIndex,:) - RawPointLocations1(k,:);

figure;
Color = linspace(1,100,length(k));
scatter3(RawPointLocations2(StartIndex:EndIndex,1),...
    RawPointLocations2(StartIndex:EndIndex,2),...
    RawPointLocations2(StartIndex:EndIndex,3),55,Color,'filled')
figure;
scatter3(RawPointLocations1(k,1),RawPointLocations1(k,2),...
    RawPointLocations1(k,3),55,Color,'filled')
