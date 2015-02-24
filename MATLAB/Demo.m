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
file_path = [DataPath '/Seismic/Velocity/SEAM/3D/BestGuessMidResTrilinear.hh@'];
OriginalSize = [1167 1334 1501];
NewSize = [176 201 76];
OriginalSpacing = [1 1 1];
[BestGuessMidResTrilinear, OutputSpacing] = DownsampleSeismicCube(file_path,OriginalSize,...
    OriginalSpacing, NewSize, 4);
%%
file_path = [DataPath '/Seismic/Velocity/Truth/vp.hh@'];
OriginalSize = [1167 1334 1501];
NewSize = [176 201 76];
OriginalSpacing = [1 1 1];
[Truth, OutputSpacing] = DownsampleSeismicCube(file_path,OriginalSize,...
    OriginalSpacing, NewSize, 4);

% path = '/Volumes/Communal/Data/Seismic/Images/seamTruth357/cstk.rsf@';
% originalSize = [584 667 600];
% newSize = [584,667,76];

%%
for i = 1:size(TruthLowRes,3)
   imagesc(TruthLowRes(:,:,i));
   colorbar;
   title([num2str(i)]);
   pause(0.25);
end



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