% This is a script to load in parts of the full SEAM Model (78 gigs)
close all;
clear all;
%File path

%file_path = '/home/lewis/Documents/SEAM/Vp_xyz_10m.bin'; %Office Computer
file_path = '/Volumes/NTFS/Vp_xyz_10m.bin'; %Home Desktop
%file_path = 'E:\home\lewis\Documents\SEAM\Vp_xyz_10m.bin';

OrigSize = [3501 4001 1501];
NewSize = [176,201,76];

% Seek forward; for now just start at beginning
fid = fopen(file_path, 'r');
fseek(fid, 0,'bof');

num_bytes_in_single = 4;
slice_size = OrigSize(1)*OrigSize(2)*num_bytes_in_single;
ScaleFactor = OrigSize./NewSize;
h = waitbar(0,'Initializing waitbar...');
lower_spatial_bound = 1152;
Output = zeros(NewSize);

for i = 1:NewSize(3)
    waitbar(i/NewSize(3),h,sprintf('%2d%%',round(i/NewSize(3)*100)));
    SeekLayer = i*ScaleFactor(3)-1;
    Lower = floor(SeekLayer);
    Upper = ceil(SeekLayer);
    fseek(fid,slice_size*Lower,'bof');
    sampleA = fread(fid, [OrigSize(1) OrigSize(2)],'single');
    
    fill_sample = GenerateSaltMask(sampleA,4480,SeekLayer);
    
    FilledSlice  = sampleA;
    if (SeekLayer < lower_spatial_bound)
        FilledSlice((fill_sample==1))=0;
        
        FilledSlice = imresize(FilledSlice,[NewSize(1) NewSize(2)],...
            'nearest');
        FilledSlice = HeatEquationFill(FilledSlice);
        
        figure(2);
        subplot(2,1,1);
        imagesc(FilledSlice);
        colorbar;
        set(gca,'clim',[1490 4800]);
        title(['Original Image. Slice: ' num2str(SeekLayer)]);
        subplot(2,1,2);
        imagesc(fill_sample);
        pause(0.25);
    end
end

close(h);








