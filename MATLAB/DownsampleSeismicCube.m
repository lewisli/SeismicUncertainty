function [ Output, OutputSpacing ] = DownsampleSeismicCube( file_path, ...
    InputSize, InputSpacing, OutputSize, num_bytes_in_single, PermutateOrder)
%DownsampleSeismicCube Downsample seismic cube
%   Detailed explanation goes here

% Seek forward; for now just start at beginning
fid = fopen(file_path, 'r');
fseek(fid, 0,'bof');

% Read double or float
if (num_bytes_in_single == 4)
    DataType = 'single';
elseif (num_bytes_in_single == 8)
    DataType = 'double';
end

slice_size = InputSize(1)*InputSize(2)*num_bytes_in_single;
ScaleFactor = InputSize./OutputSize;
h = waitbar(0,'Initializing waitbar...');

Output = zeros(OutputSize);
for i = 1:OutputSize(3)
    waitbar(i/OutputSize(3),h,sprintf('%2d%%',round(i/OutputSize(3)*100)));
    SeekLayer = i*ScaleFactor(3)-1;
    Lower = floor(SeekLayer);
    Upper = ceil(SeekLayer);
    fseek(fid,slice_size*Lower,'bof');
    
    sampleA = fread(fid, [InputSize(1) InputSize(2)],DataType);
    sampleA = imresize(sampleA,[OutputSize(1) OutputSize(2)]);
    
    fseek(fid,slice_size*Upper,'bof');
    sampleB = fread(fid, [InputSize(1) InputSize(2)],DataType);
    sampleB = imresize(sampleB,[OutputSize(1) OutputSize(2)]);
    
    if (Lower ~=Upper)
        Output(:,:,i) = (1-(SeekLayer-Lower))*sampleA+...
            (1-(Upper-SeekLayer))*sampleB;
    else
        Output(:,:,i) = sampleA;
    end
end
close(h);

% Compute new spacing
OutputSpacing = InputSpacing.*ScaleFactor;

% Permutate if necessary
if (nargin == 6)
    Output = permute(Output,PermutateOrder);
end

end

