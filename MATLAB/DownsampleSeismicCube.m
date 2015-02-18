function [ Output ] = DownsampleSeismicCube( file_path, OrigSize, NewSize )
%DownsampleSeismicCube Downsample seismic cube
%   Detailed explanation goes here

% Seek forward; for now just start at beginning
fid = fopen(file_path, 'r');
fseek(fid, 0,'bof');

num_bytes_in_single = 4;
slice_size = OrigSize(1)*OrigSize(2)*num_bytes_in_single;
ScaleFactor = OrigSize./NewSize;
h = waitbar(0,'Initializing waitbar...');

Output = zeros(NewSize);
for i = 1:NewSize(3)
    waitbar(i/NewSize(3),h,sprintf('%2d%%',round(i/NewSize(3)*100)));
    SeekLayer = i*ScaleFactor(3)-1;
    Lower = floor(SeekLayer);
    Upper = ceil(SeekLayer);
    fseek(fid,slice_size*Lower,'bof');
    sampleA = fread(fid, [OrigSize(1) OrigSize(2)],'single');
    sampleA = imresize(sampleA,[NewSize(1) NewSize(2)]);
    
    fseek(fid,slice_size*Upper,'bof');
    sampleB = fread(fid, [OrigSize(1) OrigSize(2)],'single');
    sampleB = imresize(sampleB,[NewSize(1) NewSize(2)]);
    
    if (Lower ~=Upper)  
        Output(:,:,i) = (1-(SeekLayer-Lower))*sampleA+...
            (1-(Upper-SeekLayer))*sampleB;
    else
        Output(:,:,i) = sampleA;
    end
end
close(h);

end

