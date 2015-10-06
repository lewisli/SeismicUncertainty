function [ Output ] = ReadSeismicCube( file_path, InputSize, ...
    num_bytes_in_single )
% ReadSeismicCube Read a seismic cube stored as a binary file
%
% Reads an RSF@ output binary file into MATLAB
%
% Input Parameters: 
%
% file_path: Path to image
% InputSize: Number of cells in image cube
% num_bytes_in_single: Precision (4 for float, 8 for double)
%
% Lewis Li (lewisli@stanford.edu)
% Date of Creation: Feburary 24th 2014
% Last Updated: September 23rd 2015


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


