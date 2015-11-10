% DemoAnalyzeCommonImageGathers
clear all;
clc;

% Path to loading
addpath('../');

% Path to migrated results (laptop)
%DataPath='/Volumes/Data/ResearchData/RawData/';

% Path to migrated results (OfficeComp)
DataPath='/run/media/lewisli/Scratch2/Data/MigrationResults/RSF/';

% Shot Names (
ShotNames={'cwn-026825','cwn-026833','cwn-028961','cwn-028969'};

ResultSize=[584 667 600];
InputSpacing = [6 6 2];
OutputSize = [400 400 200];

% Define Zone of Interest
InLineRange = [125 275];
CrossLineRange = [125 275];
DepthRange = [120 200];

ROI = [InLineRange; CrossLineRange; DepthRange];


%% Check if 

%% Results List
MisfitDirectory = cell(50,2);

%% Truth Misfit
BinaryPath = '/run/media/lewisli/Scratch/MigrationResults/RSF/GroundTruth/';
RealizationName = 'GroundTruth';
TruthMisfit = CalculateCIGMisfit(BinaryPath, RealizationName,ShotNames, ...
    ResultSize,InputSpacing,OutputSize,ROI);
MisfitDirectory{1,1} = RealizationName;
MisfitDirectory{1,2} = TruthMisfit;


%% Best Guess Misfit
% Bit of a misnomer, this was actually generated using Baseline ~50k
% triangluar mesh
BinaryPath = '/run/media/lewisli/Scratch/MigrationResults/RSF/BestGuessHighResolution/';
RealizationName = 'BestGuessHighResolution';
BestGuessMisfit = CalculateCIGMisfit(BinaryPath, RealizationName,ShotNames, ...
    ResultSize,InputSpacing,OutputSize,ROI);
MisfitDirectory{2,1} = RealizationName;
MisfitDirectory{2,2} = BestGuessMisfit;

%% High resolution Best Guess Misfit
% This is the one generated with the 300k+ mesh
BinaryPath = '/run/media/lewisli/Scratch2/Data/MigrationResults/RSF/HighDefBaseline/HighDefBaseline/';
RealizationName = 'BestGuessUltraDef';
BestGuessMisfit = CalculateCIGMisfit(BinaryPath, RealizationName,ShotNames, ...
    ResultSize,InputSpacing,OutputSize,ROI);
MisfitDirectory{3,1} = RealizationName;
MisfitDirectory{3,2} = BestGuessMisfit;

%% Trial 1 Realizations
% These were the realizations generated using the high resolution surface
% and an initial amplitude of 2.0

GroupName = 'Trial4'
RealizationBaseName = [GroupName '-Real-'];
NumRealizations = 1;
%CurrentNumRealizations = length(MisfitDirectory);

for i = 1:NumRealizations
    
    RealizationName = [RealizationBaseName  num2str(i)];
    BinaryPath = [DataPath GroupName '/' RealizationName '/'];
    
    Misfit = CalculateCIGMisfit(BinaryPath, RealizationName,ShotNames,ResultSize,...
        InputSpacing,OutputSize,ROI)
    
    %MisfitDirectory{i+CurrentNumRealizations,1} = RealizationName
    %MisfitDirectory{i+CurrentNumRealizations,2} = Misfit
end

%save('MisfitTableTrial3.mat','MisfitDirectory')  % function form

%% Trial 2
load('MisfitTable.mat');
CurrentTableLength = length(MisfitDirectory);

GroupName = 'Trial2'
RealizationBaseName = [GroupName '-Real-'];
NumRealizations = 49;

for i = 1:NumRealizations
     RealizationName = [RealizationBaseName  num2str(i)];
     BinaryPath = [DataPath GroupName '/' RealizationName '/'];
     
     Misfit = CalculateCIGMisfit(BinaryPath, RealizationName,ShotNames,ResultSize,...
         InputSpacing,OutputSize,ROI);
     
     MisfitDirectory{CurrentTableLength + i,1} = RealizationName;
     MisfitDirectory{CurrentTableLength + i,2} = Misfit;
     
end
%Directory{i+2,2} = Misfit;


%% Analyze Results



