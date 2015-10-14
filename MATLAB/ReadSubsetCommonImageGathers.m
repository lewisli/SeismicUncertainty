% ReadSubsetCommonImageGathers.m
%
% Read Common Image Gathers From Madagascar Results, subsample to
% reasonable resolution, convert to Sumo Format.
%
% Date: September 21st 2015
% Lewis Li

clear all;

addpath('data');

ResultsDir = '/run/media/lewisli/Scratch/MigrationResults/RSF/';

RealizationName = 'SubsetMigrationTest';



fid = fopen('64shots.txt');
tline = fgets(fid);
ShotNames = {'cwn-026825','cwn-026833', 'cwn-028961','cwn-028969'};


%% Start Parsing
for i = 1:length(ShotNames)
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
