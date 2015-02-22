function [ Output ] = ReadSeismicCube( file_path, InputSize, ...
    num_bytes_in_single )
%ReadSeismicCube Read a seismic cube stored as a binary file
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
h = waitbar(0,'Initializing waitbar...');

Output = zeros(InputSize);
for i = 1:InputSize(3)
    waitbar(i/InputSize(3),h,sprintf('%2d%%',round(i/InputSize(3)*100)));
    SeekLayer = i-1;
    fseek(fid,slice_size*SeekLayer,'bof');    
    sampleA = fread(fid, [InputSize(1) InputSize(2)],DataType);
    Output(:,:,i) = sampleA;
    
end
close(h);
close all;
end


