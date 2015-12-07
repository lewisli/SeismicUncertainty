%% AnalyzeSumoRealizationsFromDisk.m
% Function to load Velocity Models which are in SumoSurfaceBinary format and
% and compute a distance between them

clear all;
close all;
clc;
%%  Load ShapeTransformIndex
% These are the indexes required to transform high density surfaces to one
% that is on the coarser one. This was computed by ddnsearch
addpath('../data');
ShapeTransformIndex = load('FullMatchedIndex.mat');
ShapeTransformIndex = ShapeTransformIndex.k;

StartIndex = load('StartIndex.mat');
StartIndex = StartIndex.StartIndex;

%% Meta-Data For Various Trials
DataDirectory = ['/media/Scratch/VelocityModels/Sumo/Realizations/Trial'];

Trial1 = struct('TrialNumber',1,'NumPoints',3129227, 'NumPolys',6258544, ...
    'DataDir', DataDirectory, 'NumRealizations',50, 'PertubSkip', [12 8],'Remap',true);
Trial2 = struct('TrialNumber',2,'NumPoints',3129227, 'PertubSkip', [12 8],'NumPolys',6258544, ...
    'DataDir', DataDirectory, 'NumRealizations',50,'Remap',true);
Trial3 = struct('TrialNumber',3,'NumPoints',714368, 'PertubSkip', [0 8],'NumPolys',1428716, ...
    'DataDir', DataDirectory, 'NumRealizations',50, 'Remap', false,'StartIndex',StartIndex);
Trial4 = struct('TrialNumber',4,'NumPoints',714368, 'PertubSkip', [0 8],'NumPolys',1428716, ...
    'DataDir', DataDirectory, 'NumRealizations',50, 'Remap', false,'StartIndex',StartIndex);
Trial5 = struct('TrialNumber',5,'NumPoints',3129227, 'PertubSkip', [12 8],'NumPolys',6258544, ...
    'DataDir', DataDirectory, 'NumRealizations',100, 'Remap', true);

TrialMetaData = {Trial1;Trial2;Trial3;Trial4;Trial5};
clear Trial1 Trial2 Trial3 Trial4 Trial5;

%% Read Trials
PointLocations = []; Deformations = []; RealizationNames = [];

DownsampleFactor = 10;

for t = 1:length(TrialMetaData);

    [ TrialPointLocations, TrialDeformations, TrialRealizationNames ] = ...
        ReadSumoSurfaceFile( TrialMetaData{t}, ShapeTransformIndex);
    
    PointLocations = cat(3,PointLocations,downsample(TrialPointLocations,DownsampleFactor));
    Deformations = cat(2,Deformations,downsample(TrialDeformations,DownsampleFactor));
    RealizationNames = cat(1,RealizationNames,TrialRealizationNames);
end

%%

% Compute difference between realizations on the entire salt surface
TotalRealNum = length(RealizationNames);
RealizationDistanceMatrix = zeros((TotalRealNum));

h = waitbar(0,'Calculating distance matrix...');
TotalElements = TotalRealNum*TotalRealNum/2;

for i = 1:TotalRealNum
    for j = i+1:TotalRealNum
        waitbar(((i-1)*TotalRealNum+j)/TotalElements,h);
        RealizationDistanceMatrix(i,j) = mean(abs(Deformations(:,i) - Deformations(:,j)));
    end
end
close(h);
RealizationDistanceMatrix = RealizationDistanceMatrix+RealizationDistanceMatrix';
[MDSProj,e] = cmdscale(RealizationDistanceMatrix);
save('../data/RealDistanceMatrix.mat','RealizationDistanceMatrix','MDSProj');

%% Add first line of distance matrix
DistanceToStart = [mean(abs(Deformations),1)];

A = cat(1,DistanceToStart,RealizationDistanceMatrix);
A = cat(2,[0; DistanceToStart'],A);
[MDSProj,e] = cmdscale(A);
%% Plot MDS distance
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

CleanIndex = (ProxyDistances(:,1)~=-1);

MetricName = {'MSE','PSNR','SSIM'};

figure(1);
for i = 1:3
    subplot(2,2,i);
    %scatter(MDSProj(CleanIndex,2),MDSProj(CleanIndex,3),55,ProxyDistances(CleanIndex,i),'Filled');
    scatter3(MDSProj(CleanIndex,2),MDSProj(CleanIndex,3),MDSProj(CleanIndex,4),55,ProxyDistances(CleanIndex,i),'Filled');
    title(MetricName{i});
    colorbar;
end
