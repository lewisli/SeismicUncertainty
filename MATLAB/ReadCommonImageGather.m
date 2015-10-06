% ReadCommonImageGather.m
%
% Read Common Image Gathers From Madagascar Results, subsample to
% reasonable resolution, convert to Sumo Format.
%
% Date: September 21st 2015
% Lewis Li

clear all;

addpath('data');

ResultsDir = '/run/media/lewisli/Scratch/MigrationResults/RSF/';

RealizationName = 'GroundTruth';

fid = fopen('64shots.txt');
tline = fgets(fid);
ShotNames = {};
while ischar(tline)
    ShotNames = [ShotNames; tline];
    tline = fgets(fid);
end
fclose(fid);

%ShotNames = {'cstk'};

%% Start Parsing
for i = 24:length(ShotNames)
    ShotName = strrep(ShotNames{i},sprintf('\n'),'');
    
    ResultFileName = [ResultsDir RealizationName '/' ShotName '.rsf@'];
    display(['Parsing ' ResultFileName]);
    
    ResultSize=[584 667 600];
    InputSpacing = [6 6 2];
    OutputSize = [400 400 200];
    
    [Realization, ResultSpacing] = ...
        UpscaleSeismicCube(ResultFileName, ResultSize, ...
        InputSpacing,OutputSize,4);
    DataPath = '/run/media/lewisli/Scratch/MigrationResults/Sumo';
    MatrixToSumoResource([DataPath '/' RealizationName] , [ShotName],...
        Realization,size(Realization),ResultSpacing, 1);
    
    close all;
end
