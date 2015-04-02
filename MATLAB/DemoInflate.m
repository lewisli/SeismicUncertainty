% Inflate velocity model
close all;
clear all;

%DataPath = getenv('SYNCDATAPATH');
%file_path = [DataPath '/Seismic/Velocity/SEAM/3D/Set1/MeshQuality_Perlin_5_SaltRemovedMidRes_0.smh@'];
file_path = ['/run/media/lewisli/SeagateData/SEAM/BestGuessHighResolution.smh@'];
OriginalSize = [1000 1000 750];
BestGuessMidRes = ReadSeismicCube(file_path, OriginalSize,4);

%%
FullResolutionSize = [1167 1334 1501];
%FullResolutionSize = [400 500 300];
OutputFilename = [DataPath '/Seismic/Velocity/SEAM/3D/BestGuessHighRes.hh@'];

InterpolateVelocityModel( OutputFilename, BestGuessMidRes/1000, ...
    OriginalSize, FullResolutionSize );

%% Verify correctness
%[ReadInput] = ReadSeismicCube(OutputFilename,FullResolutionSize,4);
