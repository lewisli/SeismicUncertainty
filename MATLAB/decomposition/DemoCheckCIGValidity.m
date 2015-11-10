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

GroupName = 'Trial5'
RealizationBaseName = [GroupName '-Real-'];
RealizationNum = 34;

RealizationName = [RealizationBaseName  num2str(RealizationNum)];
BinaryPath = [DataPath GroupName '/' RealizationName '/'];

Misfit = CalculateCIGMisfit(BinaryPath, RealizationName,ShotNames,ResultSize,...
    InputSpacing,OutputSize,ROI)


%% Read a slice and plot to verify
BinaryPath = [DataPath GroupName '/' RealizationName '/' ShotNames{1} '.rsf@'];
GroundTruth = ['/run/media/lewisli/Scratch/MigrationResults/RSF/GroundTruth/' ShotNames{1} '.rsf@'];

CIG = UpscaleSeismicCube(BinaryPath,ResultSize,InputSpacing,OutputSize,4);
Truth = UpscaleSeismicCube(GroundTruth,ResultSize,InputSpacing,OutputSize,4);

%%
XSlice = 280;
subplot(211);
imagesc(squeeze(CIG(XSlice,:,:))')
colorbar;
colormap gray;

subplot(212);
imagesc(squeeze(Truth(XSlice,:,:))')
colorbar;
colormap gray;
