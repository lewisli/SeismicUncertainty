% Demo for downsampling Seismic Cube
path = '/Volumes/NTFS/Vp_xyz_10m.bin';
originalSize = [3501 4001 1501];
newSize = [176,201,76];

% path = '/Volumes/Communal/Data/Seismic/Images/seamTruth357/cstk.rsf@';
% originalSize = [584 667 600];
% newSize = [584,667,76];


close all;
Output = DownsampleSeismicCube(path,originalSize,newSize);

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