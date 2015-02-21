%% All data is stored under $SYNCDATAPATH, which will be synced using 
% Bitorrent Sync
DataPath = getenv('SYNCDATAPATH');

%% Demo for downsampling Seismic Cube
file_path = '/Volumes/Communal/Data/Seismic/Velocity/Truth/Vp_xyz_10m.bin';
OriginalSize = [3501 4001 1501];
OriginalSpacing = [1 1 1];
newSize = [176,201,76];
close all;
[Output, OutputSpacing] = DownsampleSeismicCube(file_path,OriginalSize,...
    OriginalSpacing, NewSize);
MatrixToSumoResource('Vp_xyz_200m',Output,NewSize,OutputSpacing, 1);


%% Demo to Downsample Illumination
file_path = '/Volumes/Communal/Data/Seismic/Illumination/ilum.rsf@';
OriginalSize = [875 1000 750];
OriginalSpacing = [4 4 2];
NewSize = [176,201,76];
close all;
[Output, OutputSpacing] = DownsampleSeismicCube(file_path,OriginalSize,...
    OriginalSpacing, NewSize);
MatrixToSumoResource('Illumination',Output,NewSize,OutputSpacing, 1);


%% Load Best Guess Reference
file_path = [DataPath '/Seismic/Sumo/BestGuessLowRes.smh@'];
OriginalSize = [176 201 76];
NewSize = [176 201 76];
OriginalSpacing = [1 1 1];
[BestGuessLowRes, OutputSpacing] = DownsampleSeismicCube(file_path,OriginalSize,...
    OriginalSpacing, NewSize,4);

%%
file_path = [DataPath '/Seismic/Sumo/TruthLowRes.smh@'];
OriginalSize = [176 201 76];
NewSize = [176 201 76];
OriginalSpacing = [1 1 1];
[TruthLowRes, OutputSpacing] = DownsampleSeismicCube(file_path,OriginalSize,...
    OriginalSpacing, NewSize, 8);

% path = '/Volumes/Communal/Data/Seismic/Images/seamTruth357/cstk.rsf@';
% originalSize = [584 667 600];
% newSize = [584,667,76];



%%
% for i = 1:newSize(3)
%    imagesc(Output(:,:,i),[-5 5]);
%    colormap gray;
%    colorbar;
%    title(num2str(i));
%    waitforbuttonpress;
% end

%% DetectSalt
OutputImage = DetectSalt(Output,[20 20 20], 4480);