function [ Deformation ] = ReadDeformations(BinaryPath, NumSkip, NumData, DataType)
%ReadDeformations Summary of this function goes here
%   Detailed explanation goes here


fid = fopen(BinaryPath, 'r');

if (fid==-1)
    display(['Could not open file: ' BinaryPath]);
    return;
end
fseek(fid, NumSkip,'bof');

% Read and cast to single to save memory
Deformation = single(fread(fid,NumData,DataType));
fclose(fid);
end

