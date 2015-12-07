% GenerateRealizationMDSPlots.m
%
% Computes distances between realizations by computing average Euclidean
% distance. Generates a MDS plot colored by proxy quality
%
% Author: Lewis Li (lewisli@stanford.edu)
% Date: November 12th 2015

%% Read in proxy log
ProxyLogPath = ['/media/Scratch2/Data/MigrationResults/ProxyResults.log'];
M = importdata(ProxyLogPath);
RealizationNames = M.textdata(2:end,1);
ProxyDistances = M.data;
ProxyNames = M.textdata(1,2:end)';

ProxyLogTruthPath = ['/media/Scratch2/Data/MigrationResults/TruthProxyResults.log'];
MTruth = importdata(ProxyLogTruthPath);
TruthName = MTruth.textdata(2:end,1);
ProxyDistancesTruth = MTruth.data;
ProxyDistances = [ProxyDistances; ProxyDistancesTruth];
RealizationNames{length(RealizationNames)+1,1} = TruthName;



%%  Load ShapeTransformIndex
% These are the indexes required to transform high density surfaces to one
% that is on the coarser one. This was computed by ddnsearch
addpath('../data');
ShapeTransformIndex = load('FullMatchedIndex.mat');
ShapeTransformIndex = ShapeTransformIndex.k;

StartIndex = load('StartIndex.mat');
StartIndex = StartIndex.StartIndex;

%% Meta Information for each trial
DataDirectory = ['/media/Scratch/VelocityModels/Sumo/Realizations/Trial'];

Trial1 = struct('TrialNumber',1,'NumPoints',3129227, 'NumPolys',6258544, ...
    'DataDir', DataDirectory, 'NumRealizations',50, 'PertubSkip', ...
    [12 8],'Remap',true);
Trial2 = struct('TrialNumber',2,'NumPoints',3129227, 'PertubSkip', ...
    [12 8],'NumPolys',6258544, ...
    'DataDir', DataDirectory, 'NumRealizations',50,'Remap',true);
Trial3 = struct('TrialNumber',3,'NumPoints',714368, 'PertubSkip', ...
    [0 8],'NumPolys',1428716, ...
    'DataDir', DataDirectory, 'NumRealizations',50, 'Remap', false,...
    'StartIndex',StartIndex);
Trial4 = struct('TrialNumber',4,'NumPoints',714368, 'PertubSkip', ...
    [0 8],'NumPolys',1428716, ...
    'DataDir', DataDirectory, 'NumRealizations',50, 'Remap', false,...
    'StartIndex',StartIndex);
Trial5 = struct('TrialNumber',5,'NumPoints',3129227, 'PertubSkip', ...
    [12 8],'NumPolys',6258544, ...
    'DataDir', DataDirectory, 'NumRealizations',100, 'Remap', true);

TrialMetaData = {Trial1;Trial2;Trial3;Trial4;Trial5};
clear Trial1 Trial2 Trial3 Trial4 Trial5;

%% Compute distances for each realization (Full resolution... takes overnight)
close all;
DistanceMatrix = zeros(length(RealizationNames));
h = waitbar(0,'Please wait...');

TotalDistances = (numel(DistanceMatrix) - length(DistanceMatrix))/2;
NumDistance = 0;

for i = 1:length(RealizationNames)
    [TrialNumberA, RealizationNumberA] = ...
        StripRealizationName(RealizationNames{i});
    
    [PointLocA,DeformationA] = ReadSumoSurface(TrialMetaData{TrialNumberA},...
        ShapeTransformIndex,RealizationNumberA);
    
    for j = i+1:length(RealizationNames)
        waitbar(NumDistance/TotalDistances,h);
        
        [TrialNumberB, RealizationNumberB] = ...
            StripRealizationName(RealizationNames{j})
        
        [PointLocB,DeformationB] = ReadSumoSurface(TrialMetaData...
            {TrialNumberB},ShapeTransformIndex,RealizationNumberB);
        
        DistanceMatrix(i,j) = mean(abs(DeformationA-DeformationB));
        NumDistance = NumDistance + 1;
    end
end

close(h);

%% Compute distance using downscaled version of distance
close all;
PointLocations = []; Deformations = [];
DownsampleFactor = 10;
TotalRealNum = length(RealizationNames);


h = waitbar(0,'Please wait...');


for i = 1:length(RealizationNames)
    
    waitbar(i/length(RealizationNames),h, ['Loading ' RealizationNames{i}]);
    
    [TrialNumber, RealizationNumber] = ...
        StripRealizationName(RealizationNames{i})    
    [TrialPointLoc,TrialDeformation] = ReadSumoSurface(TrialMetaData...
        {TrialNumber},ShapeTransformIndex,RealizationNumber);
    
    PointLocations = cat(3,PointLocations,downsample(TrialPointLoc,...
        DownsampleFactor));
    Deformations = cat(2,Deformations,downsample(TrialDeformation,...
        DownsampleFactor));
end
%%
DeformationsWithTruth = cat(2,Deformations,zeros(size(Deformations,1),1));

%%
TotalRealNum = size(DeformationsWithTruth,2);
RealizationDistanceMatrix = zeros((TotalRealNum));

h = waitbar(0,'Calculating distance matrix...');
TotalElements = (TotalRealNum-1)*TotalRealNum/2;

for i = 1:TotalRealNum
    for j = i+1:TotalRealNum
        waitbar(((i-1)*TotalRealNum+j)/TotalElements,h);
        RealizationDistanceMatrix(i,j) = mean(abs(DeformationsWithTruth(:,i) - DeformationsWithTruth(:,j)));
    end
end
close(h);
%%
RealizationDistanceMatrix = RealizationDistanceMatrix+RealizationDistanceMatrix';
[MDSProj,e] = cmdscale(RealizationDistanceMatrix);

%% Remove the ones with improper proxies
CleanProxyIndex = ProxyDistances(:,1) ~= -1;

CutIndex = 1;

MDSTruncated = MDSProj(CleanProxyIndex,:);
MDSTruncated = MDSTruncated(CutIndex:end,:);

RealizationNamesTruncated = RealizationNames(CleanProxyIndex,1);
RealizationNamesTruncated = RealizationNamesTruncated(CutIndex:end,:);

ProxyTruncated = ProxyDistances(CleanProxyIndex,1);
ProxyTruncated = ProxyTruncated(CutIndex:end,:);
%% Try in 2D First

X = MDSTruncated(:,1);
Y = MDSTruncated(:,2);
Z = MDSTruncated(:,4);

figure(1)
scatter(X,Y,55,ProxyTruncated,'Filled')
caxis([3.982227 4.5]) 
caxis([3.982227 4.3]) 
colorbar;
dx = 0.05; dy = 0.05; % displacement so the text does not overlay the data points


text(X(end-1:end)+dx, Y(end-1:end)+dy, RealizationNamesTruncated(end-1:end));



figure(2)
scatter3(X,Y,Z,55,ProxyTruncated,'Filled')
caxis([3.982227 4.2]) 
colorbar;
dx = 0.05; dy = 0.05; dz = 0.05; % displacement so the text does not overlay the data points
text(X(end-1:end)+dx, Y(end-1:end)+dy,Z(end-1:end)+dz, RealizationNamesTruncated(end-1:end));

