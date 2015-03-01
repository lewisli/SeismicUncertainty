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
path = '/Volumes/Communal/SplitMigTest/cic-028905_0.rsf@';
OriginalSize = [800 800 600];
cic_0 = ReadSeismicCube(path,OriginalSize,4);

path = '/Volumes/Communal/SplitMigTest/cic-028905_1.rsf@';
OriginalSize = [800 800 600];
cic_1 = ReadSeismicCube(path,OriginalSize,4);

path = '/Volumes/Communal/SplitMigTest/cic-028905_2.rsf@';
OriginalSize = [800 800 600];
cic_2 = ReadSeismicCube(path,OriginalSize,4);

path = '/Volumes/Communal/SplitMigTest/cic-028905_3.rsf@';
OriginalSize = [800 800 600];
cic_3 = ReadSeismicCube(path,OriginalSize,4);

%%
path = '/Volumes/Communal/SplitMigTest/cic-028905.rsf@';
OriginalSize = [800 800 600];
cic_stk = ReadSeismicCube(path,OriginalSize,4);
%%
path = '/Volumes/Communal/BestGuessTest/cic-028905.rsf@'
OriginalSize = [800 800 600];
cic_best_guess = ReadSeismicCube(path,OriginalSize,4);

%%
path = '/Volumes/Communal/SplitMigTest/cwn-028905.rsf@';
OriginalSize = [584 667 600];
cwn_split = ReadSeismicCube(path,OriginalSize,4);

%%
path = '/Volumes/Communal/BestGuessTest/cwn-028905.rsf@';
OriginalSize = [584 667 600];
cwn_best_guess = ReadSeismicCube(path,OriginalSize,4);

%%
for i = 1:600
    subplot(3,1,1)
    imagesc(cwn_split(:,:,i));
    colormap gray;
    colorbar;
    subplot(3,1,2)
    imagesc(cwn_best_guess(:,:,i));
    colormap gray;
    colorbar;
    subplot(3,1,3)
    imagesc(cwn_split(:,:,i) -cwn_best_guess(:,:,i));
    colormap gray;
    colorbar;
    
    title(num2str(i))
    pause(0.25);
end
%%
for i = 1:600
    cstk = cic_0(:,:,i)+cic_1(:,:,i)+cic_2(:,:,i)+cic_3(:,:,i);
    subplot(3,1,1)
    imagesc(cstk,[-150 150]);
    colormap gray;
    colorbar;
    subplot(3,1,2)
    imagesc(cic_best_guess(:,:,i),[-150 150]);
    colormap gray;
    colorbar;
    subplot(3,1,3)
    imagesc(cic_stk(:,:,i),[-150 150]);
    colormap gray;
    colorbar;
    
    title(num2str(i))
    pause(0.25);
end
