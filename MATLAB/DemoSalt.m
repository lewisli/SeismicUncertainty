%% Remove salt and fill
close all;
clear all;
file_path = '/run/media/lewisli/SeagateExternal/SEAM/Vp_xyz_10m.bin';
OrigSize = [3501 4001 1501];
OrigSpacing = [1 1 1];
NewSize = [350,400,150];
Num_bytes = 4;
LowerDepth = 1152;
SaltVelocity = 4480;

[Output OutputSpacing] = InterpolateSalt(file_path, OrigSize, ...
    OrigSpacing, NewSize, Num_bytes, LowerDepth, SaltVelocity);

%%
DataPath = getenv('SYNCDATAPATH');
MatrixToSumoResource([DataPath '/Seismic/Sumo'], 'SaltRemovedMidRes',Output,NewSize,OutputSpacing, 1);

