%% AnalyzeSumoRealizations.m
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


%% Meta-Data For Various Trials
DataDirectory = ['/media/Scratch/VelocityModels/Sumo/Realizations/Trial'];

Trial1 = struct('TrialNumber',1,'NumPoints',3129227, 'NumPolys',6258544, ...
    'DataDir', DataDirectory, 'NumRealizations',50, 'PertubSkip', [12 8],'Remap',true);
Trial2 = struct('TrialNumber',2,'NumPoints',3129227, 'PertubSkip', [12 8],'NumPolys',6258544, ...
    'DataDir', DataDirectory, 'NumRealizations',50,'Remap',true);
Trial3 = struct('TrialNumber',3,'NumPoints',714368, 'PertubSkip', [0 8],'NumPolys',1428716, ...
    'DataDir', DataDirectory, 'NumRealizations',50, 'Remap', false);
Trial4 = struct('TrialNumber',4,'NumPoints',714368, 'PertubSkip', [0 8],'NumPolys',1428716, ...
    'DataDir', DataDirectory, 'NumRealizations',50, 'Remap', false);
Trial5 = struct('TrialNumber',5,'NumPoints',3129227, 'PertubSkip', [12 8],'NumPolys',6258544, ...
    'DataDir', DataDirectory, 'NumRealizations',100, 'Remap', true);

TrialMetaData = {Trial1;Trial2;Trial3;Trial4;Trial5};
clear Trial1 Trial2 Trial3 Trial4 Trial5;

%% Read Trials
PointLocations = []; Deformations = []; RealizationNames = [];

for t = 1:length(TrialMetaData);

    
    [ TrialPointLocations, TrialDeformations, TrialRealizationNames ] = ...
        ReadSumoSurfaceFile( TrialMetaData{t}, ShapeTransformIndex);
    
    PointLocations = cat(3,PointLocations,TrialPointLocations);
    Deformations = cat(2,Deformations,TrialDeformations);
    RealizationNames = cat(1,RealizationNames,TrialRealizationNames);
end

%% Compute difference between realizations on the entire salt surface
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
%%
scatter3(MDSProj(:,1),MDSProj(:,2),MDSProj(:,3))