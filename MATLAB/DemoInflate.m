% Inflate velocity model
close all;
clear all;

DataPath = getenv('SYNCDATAPATH');
file_path = [DataPath '/Seismic/Sumo/BestGuessMidRes.smh@'];
OriginalSize = [350 400 150];
BestGuessMidRes = ReadSeismicCube(file_path, OriginalSize,4);

%%
%FullResolutionSize = [1167 1334 1501];
FullResolutionSize = [400 500 300];
OutputFilename = 'SampleOutput.bin';

InterpolateVelocityModel( OutputFilename, BestGuessMidRes, ...
    OriginalSize, FullResolutionSize );

%% Verify correctness
[ReadInput] = ReadSeismicCube(OutputFilename,FullResolutionSize,4);
