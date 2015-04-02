function [ Output ] = CropSeismicCube( file_path, ...
    InputSize, StartIndex, EndIndex, num_bytes_in_single)

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
OutputSize = EndIndex - StartIndex;
Output = zeros(OutputSize);
for i = 1:OutputSize(3)
    waitbar(i/OutputSize(3),h,sprintf('%2d%%',round(i/OutputSize(3)*100)));
    SeekLayer = i+StartIndex(3)-1;
    
	fseek(fid,slice_size*SeekLayer,'bof');
    
    sampleA = fread(fid, [InputSize(1) InputSize(2)],DataType);
    sampleA = sampleA(StartIndex(1):EndIndex(1)-1, StartIndex(2):EndIndex(2)-1);
    
    size(sampleA)
    size(Output)
%     figure(2);
%     imagesc(sampleA);
%     pause(0.25);
    Output(:,:,i) = sampleA;
end
close all;

end